
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.Duration;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/get-delivery-location")
public class GetDeliveryLocationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // A location is considered fresh for 60 seconds.
    private static final long LOCATION_FRESH_SECONDS = 60;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        prepareJsonResponse(response);

        HttpSession session = request.getSession(false);

        // TEMPORARY DEBUG CODE: Check the customer session.
        System.out.println("========== TRACKING DEBUG ==========");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Session exists: " + (session != null));

        if (session != null) {
            System.out.println(
                    "Session userId: " + session.getAttribute("userId"));
            System.out.println(
                    "Session role: " + session.getAttribute("role"));
        }

        System.out.println("====================================");

        // Only logged-in customers can access their order tracking.
        if (session == null
                || !(session.getAttribute("userId") instanceof Integer)
                || !"customer".equalsIgnoreCase(
                        String.valueOf(session.getAttribute("role")))) {

            System.out.println(
                    "TRACKING DEBUG: Access denied by session validation.");

            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            writeError(response, "Access denied.");
            return;
        }

        int customerId = (Integer) session.getAttribute("userId");

        int orderId;

        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException | NullPointerException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeError(response, "Invalid order ID.");
            return;
        }

        System.out.println("TRACKING DEBUG: Requested orderId = " + orderId);
        System.out.println("TRACKING DEBUG: Customer ID = " + customerId);

        String sql =
                "SELECT " +
                "o.status AS orderStatus, " +
                "da.deliveryAgentId AS assignedAgentId, " +
                "da.deliveryStatus, " +
                "dl.deliveryAgentId AS locationAgentId, " +
                "dl.latitude, " +
                "dl.longitude, " +
                "dl.updatedAt, " +
                "COALESCE(gs.isSharing, FALSE) AS sharingEnabled " +
                "FROM orders o " +
                "LEFT JOIN delivery_assignments da " +
                "ON da.orderId = o.orderId " +
                "LEFT JOIN delivery_locations dl " +
                "ON dl.orderId = o.orderId " +
                "AND dl.deliveryAgentId = da.deliveryAgentId " +
                "LEFT JOIN delivery_gps_state gs " +
                "ON gs.deliveryAgentId = da.deliveryAgentId " +
                "WHERE o.orderId = ? AND o.userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {

                // The order must exist and belong to this customer.
                if (!rs.next()) {
                    System.out.println(
                            "TRACKING DEBUG: Order not found for this customer.");

                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    writeError(response, "Order not found.");
                    return;
                }

                String orderStatus = rs.getString("orderStatus");
                String deliveryStatus = rs.getString("deliveryStatus");

                boolean delivered =
                        "Delivered".equalsIgnoreCase(orderStatus)
                        || "Delivered".equalsIgnoreCase(deliveryStatus);

                boolean cancelled =
                        isCancelled(orderStatus)
                        || isCancelled(deliveryStatus);

                int assignedAgentId = rs.getInt("assignedAgentId");
                boolean hasAssignedAgent = !rs.wasNull();

                int locationAgentId = rs.getInt("locationAgentId");
                boolean hasLocationAgent = !rs.wasNull();

                boolean sharingEnabled =
                        rs.getBoolean("sharingEnabled");

                double latitude = rs.getDouble("latitude");
                boolean hasLatitude = !rs.wasNull();

                double longitude = rs.getDouble("longitude");
                boolean hasLongitude = !rs.wasNull();

                Timestamp updatedAt = rs.getTimestamp("updatedAt");

                boolean hasCoordinates =
                        hasAssignedAgent
                        && hasLocationAgent
                        && assignedAgentId == locationAgentId
                        && hasLatitude
                        && hasLongitude;

                boolean locationFresh = false;

                if (hasCoordinates && updatedAt != null) {
                    long ageSeconds = Duration.between(
                            updatedAt.toInstant(),
                            Instant.now()).getSeconds();

                    locationFresh =
                            ageSeconds >= 0
                            && ageSeconds <= LOCATION_FRESH_SECONDS;
                }

                // TEMPORARY DEBUG CODE: Check GPS tracking data.
                System.out.println(
                        "TRACKING DEBUG: Order status = " + orderStatus);
                System.out.println(
                        "TRACKING DEBUG: Delivery status = " + deliveryStatus);
                System.out.println(
                        "TRACKING DEBUG: Assigned agent ID = "
                                + (hasAssignedAgent ? assignedAgentId : "none"));
                System.out.println(
                        "TRACKING DEBUG: Location agent ID = "
                                + (hasLocationAgent ? locationAgentId : "none"));
                System.out.println(
                        "TRACKING DEBUG: Sharing enabled = " + sharingEnabled);
                System.out.println(
                        "TRACKING DEBUG: Has coordinates = " + hasCoordinates);
                System.out.println(
                        "TRACKING DEBUG: Location fresh = " + locationFresh);
                System.out.println(
                        "TRACKING DEBUG: GPS updated at = " + updatedAt);

                // Do not expose coordinates for completed orders.
                if (delivered || cancelled) {
                    writeTrackingJson(
                            response,
                            true,
                            orderStatus,
                            deliveryStatus,
                            delivered,
                            cancelled,
                            sharingEnabled,
                            false,
                            false,
                            null,
                            null,
                            updatedAt);

                    return;
                }

                // Coordinates are live only when sharing is enabled
                // and the saved location is recent.
                boolean liveLocation =
                        sharingEnabled
                        && hasCoordinates
                        && locationFresh;

                System.out.println(
                        "TRACKING DEBUG: Live location available = "
                                + liveLocation);

                writeTrackingJson(
                        response,
                        true,
                        orderStatus,
                        deliveryStatus,
                        false,
                        false,
                        sharingEnabled,
                        locationFresh,
                        liveLocation,
                        liveLocation ? latitude : null,
                        liveLocation ? longitude : null,
                        updatedAt);
            }

        } catch (Exception e) {
            e.printStackTrace();

            throw new ServletException(
                    "Unable to retrieve delivery location.", e);
        }
    }

    private boolean isCancelled(String status) {
        return status != null
                && ("Cancelled".equalsIgnoreCase(status)
                || "Canceled".equalsIgnoreCase(status)
                || "Rejected".equalsIgnoreCase(status));
    }

    private void prepareJsonResponse(HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader(
                "Cache-Control",
                "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    private void writeTrackingJson(
            HttpServletResponse response,
            boolean success,
            String orderStatus,
            String deliveryStatus,
            boolean delivered,
            boolean cancelled,
            boolean sharingEnabled,
            boolean locationFresh,
            boolean liveLocation,
            Double latitude,
            Double longitude,
            Timestamp updatedAt) throws IOException {

        StringBuilder json = new StringBuilder();

        json.append("{")
            .append("\"success\":").append(success)
            .append(",\"orderStatus\":")
            .append(toJsonString(orderStatus))
            .append(",\"status\":")
            .append(toJsonString(orderStatus))
            .append(",\"deliveryStatus\":")
            .append(toJsonString(deliveryStatus))
            .append(",\"delivered\":").append(delivered)
            .append(",\"cancelled\":").append(cancelled)
            .append(",\"sharingEnabled\":").append(sharingEnabled)
            .append(",\"locationFresh\":").append(locationFresh)
            .append(",\"liveLocation\":").append(liveLocation);

        if (latitude != null && longitude != null) {
            json.append(",\"latitude\":").append(latitude)
                .append(",\"longitude\":").append(longitude);
        }

        if (updatedAt != null) {
            json.append(",\"updatedAt\":")
                .append(toJsonString(updatedAt.toInstant().toString()));
        }

        json.append("}");

        response.getWriter().write(json.toString());
    }

    private String toJsonString(String value) {
        if (value == null) {
            return "null";
        }

        String safe = value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");

        return "\"" + safe + "\"";
    }

    private void writeError(
            HttpServletResponse response,
            String message) throws IOException {

        response.getWriter().write(
                "{\"success\":false,\"message\":"
                + toJsonString(message) + "}");
    }
}


package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/update-delivery-location")
public class UpdateDeliveryLocationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

        HttpSession session = request.getSession(false);

        if (session == null
                || !"deliveryagent".equals(session.getAttribute("role"))
                || !(session.getAttribute("userId") instanceof Integer)) {

            sendJson(response, HttpServletResponse.SC_UNAUTHORIZED,
                    false, "Please log in as a delivery agent.");
            return;
        }

        int deliveryAgentId = (Integer) session.getAttribute("userId");

        int orderId;
        double latitude;
        double longitude;

        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
            latitude = Double.parseDouble(request.getParameter("latitude"));
            longitude = Double.parseDouble(request.getParameter("longitude"));
        } catch (NumberFormatException | NullPointerException e) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    false, "Invalid or missing order ID or coordinates.");
            return;
        }

        if (orderId <= 0
                || !Double.isFinite(latitude)
                || !Double.isFinite(longitude)
                || latitude < -90 || latitude > 90
                || longitude < -180 || longitude > 180) {

            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    false, "The order ID or GPS coordinates are invalid.");
            return;
        }

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // 1. Lock and check the order status.
            String orderSql =
                    "SELECT status FROM orders WHERE orderId = ? FOR UPDATE";

            try (PreparedStatement ps = con.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        sendJson(response, HttpServletResponse.SC_NOT_FOUND,
                                false, "Order not found.");
                        return;
                    }

                    String orderStatus = rs.getString("status");

                    if (orderStatus != null) {
                        String normalizedStatus =
                                orderStatus.trim().toLowerCase();

                        if (normalizedStatus.equals("delivered")
                                || normalizedStatus.equals("cancelled")
                                || normalizedStatus.equals("canceled")
                                || normalizedStatus.equals("rejected")) {

                            con.rollback();
                            sendJson(response, HttpServletResponse.SC_CONFLICT,
                                    false, "GPS updates are not allowed for this order.");
                            return;
                        }
                    }
                }
            }

            // 2. Confirm this agent owns an active assignment for the order.
            String assignmentSql =
                    "SELECT assignmentId FROM delivery_assignments " +
                    "WHERE orderId = ? " +
                    "AND deliveryAgentId = ? " +
                    "AND deliveryStatus IN ('Accepted', 'Picked Up', 'Out for Delivery') " +
                    "FOR UPDATE";

            try (PreparedStatement ps = con.prepareStatement(assignmentSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, deliveryAgentId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        sendJson(response, HttpServletResponse.SC_FORBIDDEN,
                                false, "You do not have an active assignment for this order.");
                        return;
                    }
                }
            }

            // 3. Check whether this delivery agent has enabled GPS sharing.
            String gpsStateSql =
                    "SELECT isSharing FROM delivery_gps_state " +
                    "WHERE deliveryAgentId = ? FOR UPDATE";

            boolean sharingEnabled = false;
            boolean stateFound = false;

            try (PreparedStatement ps = con.prepareStatement(gpsStateSql)) {
                ps.setInt(1, deliveryAgentId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stateFound = true;
                        sharingEnabled = rs.getBoolean("isSharing");
                    }
                }
            }

            if (!stateFound || !sharingEnabled) {
                con.rollback();
                sendJson(response, HttpServletResponse.SC_CONFLICT,
                        false, "GPS sharing is disabled. Start GPS sharing first.");
                return;
            }

            // 4. Save the latest coordinates for this order.
            String locationSql =
                    "INSERT INTO delivery_locations " +
                    "(orderId, deliveryAgentId, latitude, longitude) " +
                    "VALUES (?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE " +
                    "deliveryAgentId = VALUES(deliveryAgentId), " +
                    "latitude = VALUES(latitude), " +
                    "longitude = VALUES(longitude), " +
                    "updatedAt = CURRENT_TIMESTAMP";

            try (PreparedStatement ps = con.prepareStatement(locationSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, deliveryAgentId);
                ps.setDouble(3, latitude);
                ps.setDouble(4, longitude);

                ps.executeUpdate();
            }

            con.commit();

            sendJson(response, HttpServletResponse.SC_OK,
                    true, "Delivery location updated successfully.");

        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackException) {
                    rollbackException.printStackTrace();
                }
            }

            e.printStackTrace();

            sendJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    false, "Database error while updating delivery location.");

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void sendJson(HttpServletResponse response,
                          int statusCode,
                          boolean success,
                          String message) throws IOException {

        response.setStatus(statusCode);

        String safeMessage = message
                .replace("\\", "\\\\")
                .replace("\"", "\\\"");

        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":" + success
                    + ",\"message\":\"" + safeMessage + "\"}");
            out.flush();
        }
    }
}

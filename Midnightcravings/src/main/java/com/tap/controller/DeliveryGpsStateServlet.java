
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/delivery-gps-state")
public class DeliveryGpsStateServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Check that the current user is a logged-in delivery agent.
    private Integer getDeliveryAgentId(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("userId") instanceof Integer)
                || !"deliveryagent".equalsIgnoreCase(
                        String.valueOf(session.getAttribute("role")))) {

            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            writeJson(response, false, "Access denied.", null);
            return null;
        }

        return (Integer) session.getAttribute("userId");
    }

    // GET: Retrieve the saved GPS-sharing preference.
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        prepareJsonResponse(response);

        Integer deliveryAgentId = getDeliveryAgentId(request, response);

        if (deliveryAgentId == null) {
            return;
        }

        String sql =
                "SELECT isSharing " +
                "FROM delivery_gps_state " +
                "WHERE deliveryAgentId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, deliveryAgentId);

            try (ResultSet rs = ps.executeQuery()) {

                // No saved row means sharing is disabled by default.
                boolean isSharing = rs.next() && rs.getBoolean("isSharing");

                writeJson(
                        response,
                        true,
                        "GPS sharing state retrieved.",
                        isSharing);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to retrieve GPS sharing state.", e);
        }
    }

    // POST: Save the GPS-sharing preference.
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        prepareJsonResponse(response);

        Integer deliveryAgentId = getDeliveryAgentId(request, response);

        if (deliveryAgentId == null) {
            return;
        }

        String sharingValue = request.getParameter("isSharing");

        if (!"true".equalsIgnoreCase(sharingValue)
                && !"false".equalsIgnoreCase(sharingValue)) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(
                    response,
                    false,
                    "Invalid GPS sharing state.",
                    null);
            return;
        }

        boolean isSharing = Boolean.parseBoolean(sharingValue);

        String sql =
                "INSERT INTO delivery_gps_state " +
                "(deliveryAgentId, isSharing) " +
                "VALUES (?, ?) " +
                "ON DUPLICATE KEY UPDATE " +
                "isSharing = VALUES(isSharing)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, deliveryAgentId);
            ps.setBoolean(2, isSharing);

            ps.executeUpdate();

            writeJson(
                    response,
                    true,
                    isSharing
                            ? "GPS sharing preference enabled."
                            : "GPS sharing stopped.",
                    isSharing);

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to save GPS sharing state.", e);
        }
    }

    private void prepareJsonResponse(HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
    }

    private void writeJson(
            HttpServletResponse response,
            boolean success,
            String message,
            Boolean isSharing) throws IOException {

        String safeMessage = message
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");

        StringBuilder json = new StringBuilder();

        json.append("{")
            .append("\"success\":").append(success)
            .append(",\"message\":\"").append(safeMessage).append("\"");

        if (isSharing != null) {
            json.append(",\"isSharing\":").append(isSharing);
        }

        json.append("}");

        response.getWriter().write(json.toString());
    }
}

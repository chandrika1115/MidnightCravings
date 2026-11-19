
package com.tap.controller;

import java.io.IOException;
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

@WebServlet("/update-order-status")
public class UpdateOrderStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // GET requests must not change order status.
    // Redirect to the restaurant dashboard instead.
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/restaurant-orders");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        // 1. Verify restaurant login.
        if (session == null
                || session.getAttribute("userId") == null
                || !(session.getAttribute("role") instanceof String)
                || !"restaurant".equalsIgnoreCase(
                        (String) session.getAttribute("role"))) {

            response.sendRedirect(contextPath + "/login");
            return;
        }

        Object sessionUserId = session.getAttribute("userId");

        if (!(sessionUserId instanceof Integer)) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        int userId = (Integer) sessionUserId;

        // 2. Validate order ID.
        int orderId;

        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));

            if (orderId <= 0) {
                throw new NumberFormatException("Invalid order ID");
            }

        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID");
            return;
        }

        // 3. Validate requested action.
        String action = request.getParameter("action");

        String currentStatus;
        String newStatus;

        if ("accept".equals(action)) {
            currentStatus = "Pending";
            newStatus = "Confirmed";

        } else if ("reject".equals(action)) {
            currentStatus = "Pending";
            newStatus = "Rejected";

        } else if ("prepare".equals(action)) {
            currentStatus = "Confirmed";
            newStatus = "Preparing";

        } else if ("ready".equals(action)) {
            currentStatus = "Preparing";
            newStatus = "Ready for Pickup";

        } else {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order action");
            return;
        }

        String updateOrderSql =
                "UPDATE orders SET status = ? " +
                "WHERE orderId = ? " +
                "AND status = ? " +
                "AND restaurantId = (" +
                "    SELECT restaurantId " +
                "    FROM restaurant_account " +
                "    WHERE userId = ?" +
                ")";

        String rejectAssignmentSql =
                "UPDATE delivery_assignments " +
                "SET deliveryStatus = 'Rejected' " +
                "WHERE orderId = ? " +
                "AND deliveryStatus = 'Assigned'";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                // 4. Update status only if the restaurant owns the order
                // and the order is in the expected current state.
                int updatedRows;

                try (PreparedStatement ps =
                             con.prepareStatement(updateOrderSql)) {

                    ps.setString(1, newStatus);
                    ps.setInt(2, orderId);
                    ps.setString(3, currentStatus);
                    ps.setInt(4, userId);

                    updatedRows = ps.executeUpdate();
                }

                if (updatedRows != 1) {
                    con.rollback();

                    response.sendRedirect(
                            contextPath
                            + "/restaurant-orders?error=notupdated");
                    return;
                }

                // 5. Invalidate an unaccepted assignment if rejected.
                if ("reject".equals(action)) {
                    try (PreparedStatement ps =
                                 con.prepareStatement(rejectAssignmentSql)) {

                        ps.setInt(1, orderId);
                        ps.executeUpdate();
                    }
                }

                boolean assignmentAvailable = true;

                // 6. Assign a delivery agent only when food is ready.
                if ("ready".equals(action)) {
                    assignmentAvailable =
                            assignDeliveryAgent(con, orderId);
                }

                // 7. Commit order status and assignment together.
                con.commit();

                if ("ready".equals(action) && !assignmentAvailable) {
                    response.sendRedirect(
                            contextPath
                            + "/restaurant-orders?updated=success"
                            + "&assignment=pending");
                    return;
                }

                response.sendRedirect(
                        contextPath + "/restaurant-orders?updated=success");

            } catch (Exception e) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to update order status", e);
        }
    }

    /**
     * Assign an available delivery agent to an order.
     */
    private boolean assignDeliveryAgent(Connection con, int orderId)
            throws SQLException {

        String existingAssignmentSql =
                "SELECT assignmentId, deliveryStatus " +
                "FROM delivery_assignments " +
                "WHERE orderId = ? FOR UPDATE";

        try (PreparedStatement ps =
                     con.prepareStatement(existingAssignmentSql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    int assignmentId = rs.getInt("assignmentId");
                    String status = rs.getString("deliveryStatus");

                    // Preserve an existing active or completed assignment.
                    if ("Assigned".equalsIgnoreCase(status)
                            || "Accepted".equalsIgnoreCase(status)
                            || "Picked Up".equalsIgnoreCase(status)
                            || "Out for Delivery".equalsIgnoreCase(status)
                            || "Delivered".equalsIgnoreCase(status)) {
                        return true;
                    }

                    // Reassign a rejected or cancelled assignment.
                    if ("Rejected".equalsIgnoreCase(status)
                            || "Cancelled".equalsIgnoreCase(status)
                            || "Canceled".equalsIgnoreCase(status)) {

                        int agentId = findAvailableAgent(con);

                        if (agentId == -1) {
                            return false;
                        }

                        String reassignSql =
                                "UPDATE delivery_assignments " +
                                "SET deliveryAgentId = ?, " +
                                "deliveryStatus = 'Assigned', " +
                                "assignedAt = CURRENT_TIMESTAMP " +
                                "WHERE assignmentId = ? " +
                                "AND deliveryStatus = ?";

                        try (PreparedStatement updatePs =
                                     con.prepareStatement(reassignSql)) {

                            updatePs.setInt(1, agentId);
                            updatePs.setInt(2, assignmentId);
                            updatePs.setString(3, status);

                            return updatePs.executeUpdate() == 1;
                        }
                    }

                    return false;
                }
            }
        }

        // No assignment exists; find an available agent.
        int deliveryAgentId = findAvailableAgent(con);

        if (deliveryAgentId == -1) {
            return false;
        }

        String insertAssignmentSql =
                "INSERT INTO delivery_assignments " +
                "(orderId, deliveryAgentId, deliveryStatus) " +
                "VALUES (?, ?, 'Assigned')";

        try (PreparedStatement ps =
                     con.prepareStatement(insertAssignmentSql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, deliveryAgentId);

            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Finds a delivery agent who has no active deliveries.
     * Returns -1 if no agent is available.
     */
    private int findAvailableAgent(Connection con) throws SQLException {

        String agentsSql =
                "SELECT userId " +
                "FROM `user` " +
                "WHERE LOWER(TRIM(role)) = 'deliveryagent' " +
                "ORDER BY userId FOR UPDATE";

        String activeCountSql =
                "SELECT COUNT(*) " +
                "FROM delivery_assignments da " +
                "JOIN orders o ON o.orderId = da.orderId " +
                "WHERE da.deliveryAgentId = ? " +
                "AND LOWER(TRIM(da.deliveryStatus)) IN " +
                "('assigned', 'accepted', 'picked up', " +
                "'out for delivery') " +
                "AND LOWER(TRIM(o.status)) NOT IN " +
                "('delivered', 'cancelled', 'canceled', 'rejected')";

        try (PreparedStatement agentPs =
                     con.prepareStatement(agentsSql);
             ResultSet agents = agentPs.executeQuery();
             PreparedStatement countPs =
                     con.prepareStatement(activeCountSql)) {

            while (agents.next()) {
                int agentId = agents.getInt("userId");

                countPs.setInt(1, agentId);

                try (ResultSet countRs = countPs.executeQuery()) {
                    if (countRs.next() && countRs.getLong(1) == 0) {
                        return agentId;
                    }
                }
            }
        }

        return -1;
    }
}

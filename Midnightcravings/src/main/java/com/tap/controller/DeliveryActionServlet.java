
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

@WebServlet("/delivery-action")
public class DeliveryActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("userId") instanceof Integer)
                || !"deliveryagent".equalsIgnoreCase(
                    String.valueOf(session.getAttribute("role")))) {

            response.sendRedirect(contextPath + "/login");
            return;
        }

        int agentId = (Integer) session.getAttribute("userId");
        int assignmentId;

        try {
            assignmentId = Integer.parseInt(
                request.getParameter("assignmentId")
            );

            if (agentId <= 0 || assignmentId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid delivery assignment."
            );
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Missing delivery action."
            );
            return;
        }

        action = action.trim();

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            /*
             * First find the order associated with this agent's
             * assignment. The assignment is checked again under lock.
             */
            int orderId;

            String findOrderSql =
                "SELECT orderId FROM delivery_assignments " +
                "WHERE assignmentId = ? AND deliveryAgentId = ?";

            try (PreparedStatement ps =
                    con.prepareStatement(findOrderSql)) {

                ps.setInt(1, assignmentId);
                ps.setInt(2, agentId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new ActionException(
                            "This delivery is not assigned to your account."
                        );
                    }

                    orderId = rs.getInt("orderId");
                }
            }

            /*
             * Lock the order first to keep the order/assignment
             * transition serialized.
             */
            String lockOrderSql =
                "SELECT status FROM orders " +
                "WHERE orderId = ? FOR UPDATE";

            String currentOrderStatus;

            try (PreparedStatement ps =
                    con.prepareStatement(lockOrderSql)) {

                ps.setInt(1, orderId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new ActionException(
                            "The associated order does not exist."
                        );
                    }

                    currentOrderStatus = rs.getString("status");
                }
            }

            /*
             * Lock and revalidate the assignment.
             */
            String currentAssignmentStatus;

            String lockAssignmentSql =
                "SELECT deliveryStatus " +
                "FROM delivery_assignments " +
                "WHERE assignmentId = ? " +
                "AND deliveryAgentId = ? " +
                "AND orderId = ? FOR UPDATE";

            try (PreparedStatement ps =
                    con.prepareStatement(lockAssignmentSql)) {

                ps.setInt(1, assignmentId);
                ps.setInt(2, agentId);
                ps.setInt(3, orderId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new ActionException(
                            "This assignment has changed or is no longer yours."
                        );
                    }

                    currentAssignmentStatus =
                        rs.getString("deliveryStatus");
                }
            }

            if (isTerminal(currentOrderStatus)
                    || isTerminal(currentAssignmentStatus)) {
                throw new ActionException(
                    "This order or assignment is no longer active."
                );
            }

            String newAssignmentStatus;
            String newOrderStatus;

            switch (action) {

                case "accept":

                    requireStatus(currentAssignmentStatus, "Assigned");
                    requireStatus(currentOrderStatus, "Ready for Pickup");

                    newAssignmentStatus = "Accepted";

                    // The restaurant's Ready for Pickup status stays
                    // unchanged until the delivery agent collects it.
                    newOrderStatus = "Ready for Pickup";
                    break;

                case "pickup":

                    requireStatus(currentAssignmentStatus, "Accepted");
                    requireStatus(currentOrderStatus, "Ready for Pickup");

                    newAssignmentStatus = "Picked Up";
                    newOrderStatus = "Picked Up";
                    break;

                case "out-for-delivery":

                    requireStatus(currentAssignmentStatus, "Picked Up");
                    requireStatus(currentOrderStatus, "Picked Up");

                    newAssignmentStatus = "Out for Delivery";
                    newOrderStatus = "Out for Delivery";
                    break;

                case "delivered":

                    requireStatus(
                        currentAssignmentStatus,
                        "Out for Delivery"
                    );
                    requireStatus(
                        currentOrderStatus,
                        "Out for Delivery"
                    );

                    newAssignmentStatus = "Delivered";
                    newOrderStatus = "Delivered";
                    break;

                case "reject":

                    requireStatus(currentAssignmentStatus, "Assigned");
                    requireStatus(currentOrderStatus, "Ready for Pickup");

                    // Reject only this agent's assignment.
                    updateAssignmentStatus(
                        con,
                        assignmentId,
                        agentId,
                        "Rejected",
                        "Assigned"
                    );

                    int nextAgentId = findNextAgent(con, agentId);

                    if (nextAgentId == -1) {

                        // Keep the prepared order ready for reassignment.
                        con.commit();

                        session.setAttribute(
                            "deliveryMessage",
                            "Order rejected. No other delivery agent " +
                            "is available. The order remains ready for pickup."
                        );

                        response.sendRedirect(
                            contextPath + "/delivery-agent-dashboard"
                        );
                        return;
                    }

                    /*
                     * Reuse the assignment row because orderId is unique.
                     * The order remains Ready for Pickup.
                     */
                    String reassignSql =
                        "UPDATE delivery_assignments " +
                        "SET deliveryAgentId = ?, " +
                        "deliveryStatus = 'Assigned', " +
                        "assignedAt = CURRENT_TIMESTAMP " +
                        "WHERE assignmentId = ? " +
                        "AND deliveryAgentId = ? " +
                        "AND deliveryStatus = 'Rejected'";

                    try (PreparedStatement ps =
                            con.prepareStatement(reassignSql)) {

                        ps.setInt(1, nextAgentId);
                        ps.setInt(2, assignmentId);
                        ps.setInt(3, agentId);

                        if (ps.executeUpdate() != 1) {
                            throw new SQLException(
                                "Could not reassign the rejected order."
                            );
                        }
                    }

                    con.commit();

                    session.setAttribute(
                        "deliveryMessage",
                        "Order rejected and reassigned to another agent."
                    );

                    response.sendRedirect(
                        contextPath + "/delivery-agent-dashboard"
                    );
                    return;

                default:

                    throw new ActionException(
                        "Unknown delivery action."
                    );
            }

            /*
             * Update both statuses in the same transaction.
             * Expected-status checks prevent stale requests from
             * overwriting a newer state.
             */
            updateAssignmentStatus(
                con,
                assignmentId,
                agentId,
                newAssignmentStatus,
                currentAssignmentStatus
            );

            updateOrderStatus(
                con,
                orderId,
                newOrderStatus,
                currentOrderStatus
            );

            con.commit();

            session.setAttribute(
                "deliveryMessage",
                "Order #" + orderId + " updated to " +
                newAssignmentStatus + "."
            );

            response.sendRedirect(
                contextPath + "/delivery-agent-dashboard"
            );

        } catch (ActionException e) {

            rollback(con);

            session.setAttribute(
                "deliveryMessage",
                e.getMessage()
            );

            response.sendRedirect(
                contextPath + "/delivery-agent-dashboard"
            );

        } catch (Exception e) {

            rollback(con);

            log("Unable to update delivery assignment.", e);

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Unable to update delivery. Check the server console."
            );

        } finally {

            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    log("Unable to close database connection.", e);
                }
            }
        }
    }

    private boolean isTerminal(String status) {
        if (status == null) {
            return false;
        }

        return "Delivered".equalsIgnoreCase(status)
            || "Completed".equalsIgnoreCase(status)
            || "Cancelled".equalsIgnoreCase(status)
            || "Canceled".equalsIgnoreCase(status)
            || "Rejected".equalsIgnoreCase(status);
    }

    private void requireStatus(String actual, String expected)
            throws ActionException {

        if (!expected.equalsIgnoreCase(
                actual == null ? "" : actual.trim())) {

            throw new ActionException(
                "Expected status '" + expected +
                "', but the current status is '" + actual +
                "'. Refresh the dashboard and retry."
            );
        }
    }

    private void updateAssignmentStatus(
            Connection con,
            int assignmentId,
            int agentId,
            String newStatus,
            String expectedStatus)
            throws SQLException, ActionException {

        String sql =
            "UPDATE delivery_assignments " +
            "SET deliveryStatus = ? " +
            "WHERE assignmentId = ? " +
            "AND deliveryAgentId = ? " +
            "AND deliveryStatus = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, assignmentId);
            ps.setInt(3, agentId);
            ps.setString(4, expectedStatus);

            if (ps.executeUpdate() != 1) {
                throw new ActionException(
                    "The assignment changed. Refresh and retry."
                );
            }
        }
    }

    private int findNextAgent(
            Connection con,
            int excludedAgentId)
            throws SQLException {

        String sql =
            "SELECT u.userId, " +
            "(SELECT COUNT(*) " +
            " FROM delivery_assignments da " +
            " JOIN orders o ON da.orderId = o.orderId " +
            " WHERE da.deliveryAgentId = u.userId " +
            " AND da.deliveryStatus NOT IN " +
            " ('Delivered', 'Cancelled', 'Canceled', 'Rejected') " +
            " AND o.status NOT IN " +
            " ('Delivered', 'Cancelled', 'Canceled', 'Rejected') " +
            ") AS activeCount " +
            "FROM `user` u " +
            "WHERE u.role = 'deliveryagent' " +
            "AND u.userId <> ? " +
            "ORDER BY activeCount ASC, u.userId ASC " +
            "LIMIT 1";

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, excludedAgentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("userId");
                }
            }
        }

        return -1;
    }

    private void updateOrderStatus(
            Connection con,
            int orderId,
            String newStatus,
            String expectedStatus)
            throws SQLException, ActionException {

        String sql =
            "UPDATE orders SET status = ? " +
            "WHERE orderId = ? AND status = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            ps.setString(3, expectedStatus);

            if (ps.executeUpdate() != 1) {
                throw new ActionException(
                    "The order status changed unexpectedly. " +
                    "Refresh and check the order."
                );
            }
        }
    }

    private void rollback(Connection con) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException e) {
                log("Transaction rollback failed.", e);
            }
        }
    }

    private static class ActionException extends Exception {

        private static final long serialVersionUID = 1L;

        ActionException(String message) {
            super(message);
        }
    }
}

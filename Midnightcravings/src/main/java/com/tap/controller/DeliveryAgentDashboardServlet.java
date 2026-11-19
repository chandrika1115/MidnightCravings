
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/delivery-agent-dashboard")
public class DeliveryAgentDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        // Check whether a user is logged in.
        if (session == null
                || session.getAttribute("userId") == null) {

            response.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        // Allow only delivery agents.
        String role = (String) session.getAttribute("role");

        if (!"deliveryagent".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        Object userIdObject = session.getAttribute("userId");

        if (!(userIdObject instanceof Integer)) {
            response.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        int deliveryAgentId = (Integer) userIdObject;

        List<Delivery> deliveries = new ArrayList<>();

        // Fetch only active assignments for this delivery agent.
        // Restaurant-rejected orders must not appear.
        String sql =
                "SELECT da.assignmentId, da.orderId, " +
                "da.assignedAt, da.deliveryStatus, " +
                "o.orderDate, o.totalAmount, " +
                "o.status AS orderStatus, " +
                "o.paymentMethod, o.deliveryAddress, " +
                "r.name AS restaurantName, " +
                "r.address AS restaurantAddress " +
                "FROM delivery_assignments da " +
                "JOIN orders o ON da.orderId = o.orderId " +
                "JOIN restaurant r " +
                "ON o.restaurantId = r.restaurantId " +
                "WHERE da.deliveryAgentId = ? " +
                "AND da.deliveryStatus IN " +
                "('Assigned', 'Accepted', 'Picked Up', " +
                "'Out for Delivery') " +
                "AND o.status <> 'Rejected' " +
                "ORDER BY da.assignedAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, deliveryAgentId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Delivery delivery = new Delivery();

                    delivery.setAssignmentId(
                            rs.getInt("assignmentId"));

                    delivery.setOrderId(
                            rs.getInt("orderId"));

                    java.sql.Timestamp assignedAt =
                            rs.getTimestamp("assignedAt");

                    delivery.setAssignedAt(
                            assignedAt != null
                                    ? assignedAt.toString()
                                    : "");

                    delivery.setDeliveryStatus(
                            rs.getString("deliveryStatus"));

                    java.sql.Timestamp orderDate =
                            rs.getTimestamp("orderDate");

                    delivery.setOrderDate(
                            orderDate != null
                                    ? orderDate.toString()
                                    : "");

                    java.math.BigDecimal amount =
                            rs.getBigDecimal("totalAmount");

                    delivery.setTotalAmount(
                            amount != null
                                    ? amount.toPlainString()
                                    : "0.00");

                    delivery.setOrderStatus(
                            rs.getString("orderStatus"));

                    delivery.setPaymentMethod(
                            rs.getString("paymentMethod"));

                    delivery.setDeliveryAddress(
                            rs.getString("deliveryAddress"));

                    delivery.setRestaurantName(
                            rs.getString("restaurantName"));

                    delivery.setRestaurantAddress(
                            rs.getString("restaurantAddress"));

                    deliveries.add(delivery);
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load assigned deliveries.", e);
        }

        // Send the active deliveries to the JSP.
        request.setAttribute("deliveries", deliveries);

        request.getRequestDispatcher(
                "/DeliveryAgentDashboard.jsp")
                .forward(request, response);
    }

    public static class Delivery {

        private int assignmentId;
        private int orderId;
        private String assignedAt;
        private String deliveryStatus;
        private String orderDate;
        private String totalAmount;
        private String orderStatus;
        private String paymentMethod;
        private String deliveryAddress;
        private String restaurantName;
        private String restaurantAddress;

        public int getAssignmentId() {
            return assignmentId;
        }

        public void setAssignmentId(int assignmentId) {
            this.assignmentId = assignmentId;
        }

        public int getOrderId() {
            return orderId;
        }

        public void setOrderId(int orderId) {
            this.orderId = orderId;
        }

        public String getAssignedAt() {
            return assignedAt;
        }

        public void setAssignedAt(String assignedAt) {
            this.assignedAt = assignedAt;
        }

        public String getDeliveryStatus() {
            return deliveryStatus;
        }

        public void setDeliveryStatus(String deliveryStatus) {
            this.deliveryStatus = deliveryStatus;
        }

        public String getOrderDate() {
            return orderDate;
        }

        public void setOrderDate(String orderDate) {
            this.orderDate = orderDate;
        }

        public String getTotalAmount() {
            return totalAmount;
        }

        public void setTotalAmount(String totalAmount) {
            this.totalAmount = totalAmount;
        }

        public String getOrderStatus() {
            return orderStatus;
        }

        public void setOrderStatus(String orderStatus) {
            this.orderStatus = orderStatus;
        }

        public String getPaymentMethod() {
            return paymentMethod;
        }

        public void setPaymentMethod(String paymentMethod) {
            this.paymentMethod = paymentMethod;
        }

        public String getDeliveryAddress() {
            return deliveryAddress;
        }

        public void setDeliveryAddress(String deliveryAddress) {
            this.deliveryAddress = deliveryAddress;
        }

        public String getRestaurantName() {
            return restaurantName;
        }

        public void setRestaurantName(String restaurantName) {
            this.restaurantName = restaurantName;
        }

        public String getRestaurantAddress() {
            return restaurantAddress;
        }

        public void setRestaurantAddress(String restaurantAddress) {
            this.restaurantAddress = restaurantAddress;
        }
    }
}

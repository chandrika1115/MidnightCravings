
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/track-order")
public class TrackOrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check whether the customer is logged in
        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect(
                    request.getContextPath() + "/Login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        // Read orderId from the URL
        String orderIdParam = request.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Order ID is missing.");
            return;
        }

        int orderId;

        try {
            orderId = Integer.parseInt(orderIdParam.trim());

            if (orderId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid order ID.");
                return;
            }

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID.");
            return;
        }

        String orderSql =
                "SELECT o.orderId, o.orderDate, o.totalAmount, " +
                "o.status, o.paymentMethod, o.deliveryAddress, " +
                "r.name AS restaurantName " +
                "FROM orders o " +
                "JOIN restaurant r ON o.restaurantId = r.restaurantId " +
                "WHERE o.orderId = ? AND o.userId = ?";

        String itemsSql =
                "SELECT m.itemName, oi.quantity, oi.itemTotal " +
                "FROM orderItem oi " +
                "JOIN menu m ON oi.menuId = m.menuId " +
                "WHERE oi.orderId = ?";

        try (Connection con = DBConnection.getConnection()) {

            // Fetch order details belonging to the logged-in customer
            try (PreparedStatement ps = con.prepareStatement(orderSql)) {

                ps.setInt(1, orderId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        response.sendError(
                                HttpServletResponse.SC_NOT_FOUND,
                                "Order not found for the logged-in user.");
                        return;
                    }

                    // Store order information for track-order.jsp
                    Map<String, Object> order = new HashMap<>();

                    order.put("orderId", rs.getInt("orderId"));
                    order.put("orderDate", rs.getTimestamp("orderDate"));
                    order.put("totalAmount", rs.getBigDecimal("totalAmount"));
                    order.put("status", rs.getString("status"));
                    order.put("paymentMethod", rs.getString("paymentMethod"));
                    order.put("deliveryAddress", rs.getString("deliveryAddress"));
                    order.put("restaurantName", rs.getString("restaurantName"));

                    request.setAttribute("order", order);
                }
            }

            // Fetch items belonging to this order
            List<Map<String, Object>> orderItems = new ArrayList<>();

            try (PreparedStatement ps = con.prepareStatement(itemsSql)) {

                ps.setInt(1, orderId);

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();

                        item.put("itemName", rs.getString("itemName"));
                        item.put("quantity", rs.getInt("quantity"));
                        item.put("itemTotal", rs.getBigDecimal("itemTotal"));

                        orderItems.add(item);
                    }
                }
            }

            request.setAttribute("orderItems", orderItems);

            // Display the tracking page
            request.getRequestDispatcher("/track-order.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();

            throw new ServletException(
                    "Unable to retrieve order tracking details.", e);
        }
    }
}

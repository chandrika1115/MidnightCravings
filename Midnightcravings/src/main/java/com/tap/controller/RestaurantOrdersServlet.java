
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.tap.Model.RestaurantOrder;
import com.tap.Model.RestaurantOrderItem;
import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/restaurant-orders")
public class RestaurantOrdersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userId") == null ||
            !"restaurant".equalsIgnoreCase(
                (String) session.getAttribute("role"))) {

            response.sendRedirect(
                request.getContextPath() + "/Login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String sql =
            "SELECT o.orderId, o.orderDate, o.totalAmount, " +
            "o.status, o.paymentMethod, o.deliveryAddress, " +
            "u.username, oi.menuId, m.itemName, " +
            "oi.quantity, oi.itemTotal " +
            "FROM restaurant_account ra " +
            "JOIN orders o ON o.restaurantId = ra.restaurantId " +
            "JOIN `user` u ON u.userId = o.userId " +
            "JOIN orderItem oi ON oi.orderId = o.orderId " +
            "JOIN menu m ON m.menuId = oi.menuId " +
            "WHERE ra.userId = ? " +
            "ORDER BY o.orderDate DESC, o.orderId DESC";

        Map<Integer, RestaurantOrder> orderMap =
            new LinkedHashMap<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    int orderId = rs.getInt("orderId");

                    RestaurantOrder order = orderMap.get(orderId);

                    if (order == null) {
                        order = new RestaurantOrder();

                        order.setOrderId(orderId);
                        order.setOrderDate(
                            rs.getTimestamp("orderDate"));
                        order.setTotalAmount(
                            rs.getBigDecimal("totalAmount"));
                        order.setStatus(rs.getString("status"));
                        order.setPaymentMethod(
                            rs.getString("paymentMethod"));
                        order.setDeliveryAddress(
                            rs.getString("deliveryAddress"));
                        order.setCustomerName(
                            rs.getString("username"));

                        orderMap.put(orderId, order);
                    }

                    RestaurantOrderItem item =
                        new RestaurantOrderItem(
                            rs.getInt("menuId"),
                            rs.getString("itemName"),
                            rs.getInt("quantity"),
                            rs.getBigDecimal("itemTotal")
                        );

                    order.getItems().add(item);
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load restaurant orders.", e);
        }

        List<RestaurantOrder> orders =
            new ArrayList<>(orderMap.values());

        request.setAttribute("orders", orders);

        request.getRequestDispatcher(
            "/restaurant-orders.jsp").forward(request, response);
    }
}

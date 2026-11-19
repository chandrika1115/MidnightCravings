
package com.tap.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Map;

import com.tap.Model.Cart;
import com.tap.Model.CartItem;
import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/place-order")
public class PlaceOrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final double DELIVERY_FEE = 40.00;
    private static final double TAXES = 15.00;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        // 1. Validate customer login.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(
                    session.getAttribute("userId").toString());
        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // 2. Retrieve the cart from the session.
        Object cartObject = session.getAttribute("cart");

        if (!(cartObject instanceof Cart)) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        Cart cart = (Cart) cartObject;
        Map<Integer, CartItem> items = cart.getItems();

        if (items == null || items.isEmpty()) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        // 3. Validate the delivery address.
        String deliveryAddress = request.getParameter("deliveryAddress");

        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            deliveryAddress = request.getParameter("address");
        }

        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            request.setAttribute(
                    "errorMessage",
                    "Please enter your delivery address.");

            request.getRequestDispatcher("/cart.jsp")
                    .forward(request, response);
            return;
        }

        deliveryAddress = deliveryAddress.trim();

        // 4. Validate the payment method.
        String paymentMethod = request.getParameter("paymentMethod");

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "COD";
        }

        if (!"COD".equalsIgnoreCase(paymentMethod.trim())) {
            request.setAttribute(
                    "errorMessage",
                    "Only Cash on Delivery is currently supported.");

            request.getRequestDispatcher("/cart.jsp")
                    .forward(request, response);
            return;
        }

        // 5. Validate items and calculate the subtotal on the server.
        int restaurantId = cart.getRestaurantId();
        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : items.values()) {

            if (item == null
                    || item.getQuantity() <= 0
                    || !Double.isFinite(item.getPrice())
                    || item.getPrice() < 0) {

                response.sendRedirect(contextPath + "/cart");
                return;
            }

            if (restaurantId == 0) {
                restaurantId = item.getRestaurantId();
            }

            if (item.getRestaurantId() != restaurantId) {
                request.setAttribute(
                        "errorMessage",
                        "Please order from one restaurant at a time.");

                request.getRequestDispatcher("/cart.jsp")
                        .forward(request, response);
                return;
            }

            BigDecimal itemSubtotal =
                    BigDecimal.valueOf(item.getPrice())
                            .multiply(BigDecimal.valueOf(item.getQuantity()));

            subtotal = subtotal.add(itemSubtotal);
        }

        if (restaurantId <= 0) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        BigDecimal totalAmount = subtotal
                .add(BigDecimal.valueOf(DELIVERY_FEE))
                .add(BigDecimal.valueOf(TAXES));

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // 6. Create the order as Pending.
            // No delivery assignment is created at checkout.
            String orderSql =
                    "INSERT INTO orders " +
                    "(userId, restaurantId, totalAmount, status, " +
                    "paymentMethod, deliveryAddress) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

            int orderId;

            try (PreparedStatement ps = con.prepareStatement(
                    orderSql, Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, userId);
                ps.setInt(2, restaurantId);
                ps.setBigDecimal(3, totalAmount);
                ps.setString(4, "Pending");
                ps.setString(5, "COD");
                ps.setString(6, deliveryAddress);

                if (ps.executeUpdate() == 0) {
                    throw new SQLException(
                            "Order could not be created.");
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {

                    if (!rs.next()) {
                        throw new SQLException(
                                "Could not retrieve the generated order ID.");
                    }

                    orderId = rs.getInt(1);
                }
            }

            // 7. Save all order items.
            String itemSql =
                    "INSERT INTO orderItem " +
                    "(orderId, menuId, quantity, itemTotal) " +
                    "VALUES (?, ?, ?, ?)";

            try (PreparedStatement ps = con.prepareStatement(itemSql)) {

                for (CartItem item : items.values()) {

                    BigDecimal itemTotal =
                            BigDecimal.valueOf(item.getPrice())
                                    .multiply(BigDecimal.valueOf(
                                            item.getQuantity()));

                    ps.setInt(1, orderId);
                    ps.setInt(2, item.getMenuId());
                    ps.setInt(3, item.getQuantity());
                    ps.setBigDecimal(4, itemTotal);

                    ps.addBatch();
                }

                ps.executeBatch();
            }

            // 8. Commit the order and its items together.
            con.commit();

            // 9. Clear the cart only after a successful commit.
            session.removeAttribute("cart");
            session.setAttribute("lastOrderId", orderId);
            session.setAttribute(
                    "assignmentMessage",
                    "Your order has been placed successfully. " +
                    "A delivery agent will be assigned when your food is ready.");

            // 10. Show the order success page.
            response.sendRedirect(
                    contextPath + "/order-success.jsp");

        } catch (Exception e) {

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackException) {
                    e.addSuppressed(rollbackException);
                }
            }

            throw new ServletException(
                    "Unable to place your order.", e);

        } finally {

            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    log("Unable to close the order connection.", e);
                }
            }
        }
    }
}

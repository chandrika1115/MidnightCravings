

package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tap.Model.Cart;
import com.tap.Model.CartItem;
import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/reorder")
public class ReorderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null ||
            !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
            if (orderId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(
                contextPath + "/order-history.jsp?reorder=invalid"
            );
            return;
        }

        Cart existingCart = (Cart) session.getAttribute("cart");

        // Do not overwrite items already in the user's cart.
        if (existingCart != null &&
            existingCart.getItems() != null &&
            !existingCart.getItems().isEmpty()) {

            response.sendRedirect(
                contextPath + "/order-history.jsp?reorder=cart-not-empty"
            );
            return;
        }

        String orderSql =
            "SELECT orderId FROM orders WHERE orderId = ? AND userId = ?";

        String itemsSql =
            "SELECT oi.menuId, oi.quantity, m.restaurantId, " +
            "m.itemName, m.price, m.imagePath, m.available " +
            "FROM orderItem oi " +
            "JOIN menu m ON oi.menuId = m.menuId " +
            "WHERE oi.orderId = ?";

        List<CartItem> reorderItems = new ArrayList<>();
        int restaurantId = -1;

        try (Connection con = DBConnection.getConnection()) {

            // Confirm this order belongs to the logged-in user.
            try (PreparedStatement ps = con.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(
                            contextPath + "/order-history.jsp?reorder=not-found"
                        );
                        return;
                    }
                }
            }

            // Fetch the original items using current menu details.
            try (PreparedStatement ps = con.prepareStatement(itemsSql)) {
                ps.setInt(1, orderId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {

                        int menuId = rs.getInt("menuId");
                        int quantity = rs.getInt("quantity");
                        int itemRestaurantId = rs.getInt("restaurantId");
                        String itemName = rs.getString("itemName");
                        double price = rs.getDouble("price");
                        String imagePath = rs.getString("imagePath");
                        boolean available = rs.getInt("available") == 1;

                        if (!available || quantity <= 0) {
                            response.sendRedirect(
                                contextPath +
                                "/order-history.jsp?reorder=unavailable"
                            );
                            return;
                        }

                        // The cart supports items from one restaurant only.
                        if (restaurantId != -1 &&
                            restaurantId != itemRestaurantId) {

                            response.sendRedirect(
                                contextPath +
                                "/order-history.jsp?reorder=invalid-items"
                            );
                            return;
                        }

                        restaurantId = itemRestaurantId;

                        reorderItems.add(
                            new CartItem(
                                menuId,
                                itemRestaurantId,
                                itemName,
                                quantity,
                                price,
                                imagePath
                            )
                        );
                    }
                }
            }

            if (reorderItems.isEmpty()) {
                response.sendRedirect(
                    contextPath + "/order-history.jsp?reorder=no-items"
                );
                return;
            }

            Cart newCart = new Cart();

            for (CartItem item : reorderItems) {
                newCart.addItem(item);
            }

            session.setAttribute("cart", newCart);

            response.sendRedirect(contextPath + "/cart");

        } catch (Exception e) {
            throw new ServletException("Unable to reorder this order.", e);
        }
    }
}

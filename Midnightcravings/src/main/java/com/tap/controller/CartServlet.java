
package com.tap.controller;

import java.io.IOException;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.DAO.MenuDAO;
import com.tap.DAOimpl.MenuDAOImpl;
import com.tap.Model.Cart;
import com.tap.Model.CartItem;
import com.tap.Model.Menu;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Cart cart = (Cart) session.getAttribute("cart");

        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }

        String action = request.getParameter("action");

        int menuId = 0;
        String menuIdParam = request.getParameter("menuId");

        if (menuIdParam != null && !menuIdParam.trim().isEmpty()) {
            try {
                menuId = Integer.parseInt(menuIdParam);
            } catch (NumberFormatException e) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid menu ID"
                );
                return;
            }
        }

        if ("add".equals(action) || "update".equals(action)) {

            int quantity;

            try {
                quantity = Integer.parseInt(
                    request.getParameter("quantity")
                );
            } catch (NumberFormatException e) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid quantity"
                );
                return;
            }

            MenuDAO menuDAO = new MenuDAOImpl();
            Menu menuItem = menuDAO.getMenu(menuId);

            if (menuItem == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Menu item not found"
                );
                return;
            }

            int newItemRestaurantId = menuItem.getRestaurantId();

            // Allow items from only one restaurant at a time.
            if (quantity > 0
                    && !cart.getItems().isEmpty()
                    && cart.getRestaurantId() != newItemRestaurantId) {

                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.setContentType("text/plain");
                response.getWriter().write("DIFFERENT_RESTAURANT");
                return;
            }

            if (quantity <= 0) {
                cart.removeItem(menuId);
            } else {

                // Include the image path in the cart item.
                CartItem cartItem = new CartItem(
                    menuItem.getMenuId(),
                    menuItem.getRestaurantId(),
                    menuItem.getItemName(),
                    quantity,
                    menuItem.getPrice(),
                    menuItem.getImagePath()
                );

                cart.addItem(cartItem);
            }

        } else if ("remove".equals(action)) {

            cart.removeItem(menuId);

        } else if ("clear".equals(action)) {

            cart.clear();

        } else {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid cart action"
            );
            return;
        }

        response.setStatus(HttpServletResponse.SC_OK);
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");

        if ("getCount".equals(action)) {

            int totalCount = 0;

            if (cart != null && cart.getItems() != null) {
                for (CartItem item : cart.getItems().values()) {
                    totalCount += item.getQuantity();
                }
            }

            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(String.valueOf(totalCount));

        } else if ("getCartItems".equals(action)) {

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            StringBuilder json = new StringBuilder("{");

            if (cart != null
                    && cart.getItems() != null
                    && !cart.getItems().isEmpty()) {

                Map<Integer, CartItem> items = cart.getItems();
                int count = 0;

                for (Map.Entry<Integer, CartItem> entry
                        : items.entrySet()) {

                    json.append("\"")
                        .append(entry.getKey())
                        .append("\":")
                        .append(entry.getValue().getQuantity());

                    if (++count < items.size()) {
                        json.append(",");
                    }
                }
            }

            json.append("}");

            response.getWriter().write(json.toString());

        } else {

            request.getRequestDispatcher("Cart.jsp")
                   .forward(request, response);
        }
    }
}

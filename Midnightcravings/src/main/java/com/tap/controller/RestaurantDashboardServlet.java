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

// Keep this commented if your web.xml already maps this servlet.
// Otherwise, uncomment it.
//@WebServlet("/restaurant-dashboard")
public class RestaurantDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // 1. Check login.
        if (session == null ||
            session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/Login.jsp"
            );
            return;
        }

        // 2. Allow restaurant accounts only.
        String role = (String) session.getAttribute("role");

        if (!"restaurant".equalsIgnoreCase(role)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied."
            );
            return;
        }

        Object sessionUserId = session.getAttribute("userId");

        if (!(sessionUserId instanceof Integer)) {
            response.sendError(
                HttpServletResponse.SC_UNAUTHORIZED,
                "Invalid login session."
            );
            return;
        }

        int userId = (Integer) sessionUserId;

        String restaurantSql =
            "SELECT r.restaurantId, r.name " +
            "FROM restaurant_account ra " +
            "JOIN restaurant r ON ra.restaurantId = r.restaurantId " +
            "WHERE ra.userId = ?";

        try (Connection con = DBConnection.getConnection()) {

            int restaurantId;
            String restaurantName;

            // 3. Find the restaurant linked to this account.
            try (PreparedStatement ps =
                    con.prepareStatement(restaurantSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "No restaurant is linked to this account."
                        );
                        return;
                    }

                    restaurantId = rs.getInt("restaurantId");
                    restaurantName = rs.getString("name");
                }
            }

            // 4. Count incoming orders awaiting a decision.
            int newOrdersCount = getOrderCount(
                con,
                restaurantId,
                "LOWER(TRIM(status)) IN ('pending', 'new', 'placed')",
                false
            );

            // 5. Count orders currently being prepared.
            int preparingOrdersCount = getOrderCount(
                con,
                restaurantId,
                "LOWER(TRIM(status)) = 'preparing'",
                false
            );

            // 6. Count orders ready for pickup.
            int readyOrdersCount = getOrderCount(
                con,
                restaurantId,
                "LOWER(TRIM(status)) IN " +
                "('ready', 'ready for pickup', 'ready_for_pickup')",
                false
            );

            // 7. Count all orders received today.
            int todayOrdersCount = getOrderCount(
                con,
                restaurantId,
                "1 = 1",
                true
            );

            // 8. Send data to the dashboard JSP.
            request.setAttribute("restaurantId", restaurantId);
            request.setAttribute("restaurantName", restaurantName);

            request.setAttribute(
                "newOrdersCount", newOrdersCount
            );

            request.setAttribute(
                "preparingOrdersCount", preparingOrdersCount
            );

            request.setAttribute(
                "readyOrdersCount", readyOrdersCount
            );

            request.setAttribute(
                "todayOrdersCount", todayOrdersCount
            );

            request.getRequestDispatcher(
                "/restaurant-dashboard.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load restaurant dashboard.", e
            );
        }
    }

    /**
     * Counts orders belonging to one restaurant.
     *
     * Uses the existing orders table.
     */
    private int getOrderCount(
            Connection con,
            int restaurantId,
            String condition,
            boolean todayOnly) throws SQLException {

        String sql =
            "SELECT COUNT(*) " +
            "FROM orders " +
            "WHERE restaurantId = ? " +
            "AND " + condition;

        if (todayOnly) {
            sql += " AND orderDate >= CURDATE() " +
                   "AND orderDate < CURDATE() + INTERVAL 1 DAY";
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }
}
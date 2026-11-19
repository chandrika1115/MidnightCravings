
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tap.DAOimpl.FeedbackDAOImpl;
import com.tap.Model.Feedback;
import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FeedbackDAOImpl feedbackDAO = new FeedbackDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        int userId;
        int orderId;
        int rating;

        try {
            userId = Integer.parseInt(
                    String.valueOf(session.getAttribute("userId")));

            orderId = Integer.parseInt(request.getParameter("orderId"));
            rating = Integer.parseInt(request.getParameter("rating"));

        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID or rating.");
            return;
        }

        if (userId <= 0 || orderId <= 0 || rating < 1 || rating > 5) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please provide a valid order ID and rating from 1 to 5.");
            return;
        }

        String comment = request.getParameter("comment");

        if (comment != null) {
            comment = comment.trim();

            if (comment.length() > 500) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Comment cannot exceed 500 characters.");
                return;
            }

            if (comment.isEmpty()) {
                comment = null;
            }
        }

        int restaurantId;

        String sql = "SELECT restaurantId, status FROM orders "
                   + "WHERE orderId = ? AND userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Order not found or does not belong to you.");
                    return;
                }

                String orderStatus = rs.getString("status");

                if (!isDelivered(orderStatus)) {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Feedback is available only for delivered orders.");
                    return;
                }

                restaurantId = rs.getInt("restaurantId");
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to verify the order.", e);
        }

        // IMPORTANT: Use /track-order, matching TrackOrderServlet.
        String trackingUrl = contextPath + "/track-order?orderId=" + orderId;

        if (feedbackDAO.hasFeedbackForOrder(orderId)) {
            response.sendRedirect(trackingUrl + "&feedback=alreadySubmitted");
            return;
        }

        Feedback feedback = new Feedback(
                orderId,
                userId,
                restaurantId,
                rating,
                comment
        );

        boolean saved = feedbackDAO.addFeedback(feedback);

        if (saved) {
            response.sendRedirect(trackingUrl + "&feedback=success");
        } else {
            response.sendRedirect(trackingUrl + "&feedback=failed");
        }
    }

    private boolean isDelivered(String status) {
        return status != null
                && status.trim()
                          .replace('_', ' ')
                          .replace('-', ' ')
                          .equalsIgnoreCase("DELIVERED");
    }
}

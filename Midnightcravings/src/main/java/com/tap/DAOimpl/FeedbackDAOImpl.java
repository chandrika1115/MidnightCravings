
package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.FeedbackDAO;
import com.tap.Model.Feedback;
import com.tap.utility.DBConnection;

public class FeedbackDAOImpl implements FeedbackDAO {

    @Override
    public boolean addFeedback(Feedback feedback) {

        String sql = "INSERT INTO feedback "
                + "(orderId, userId, restaurantId, rating, comment) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, feedback.getOrderId());
            ps.setInt(2, feedback.getUserId());
            ps.setInt(3, feedback.getRestaurantId());
            ps.setInt(4, feedback.getRating());
            ps.setString(5, feedback.getComment());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean hasFeedbackForOrder(int orderId) {

        String sql = "SELECT 1 FROM feedback WHERE orderId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Feedback> getFeedbackByRestaurantId(int restaurantId) {

        List<Feedback> feedbackList = new ArrayList<>();

        String sql = "SELECT feedbackId, orderId, userId, restaurantId, "
                + "rating, comment, createdAt "
                + "FROM feedback WHERE restaurantId = ? "
                + "ORDER BY createdAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Feedback feedback = new Feedback();

                    feedback.setFeedbackId(rs.getInt("feedbackId"));
                    feedback.setOrderId(rs.getInt("orderId"));
                    feedback.setUserId(rs.getInt("userId"));
                    feedback.setRestaurantId(rs.getInt("restaurantId"));
                    feedback.setRating(rs.getInt("rating"));
                    feedback.setComment(rs.getString("comment"));
                    feedback.setCreatedAt(rs.getTimestamp("createdAt"));

                    feedbackList.add(feedback);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return feedbackList;
    }

    @Override
    public double getAverageRating(int restaurantId) {

        String sql = "SELECT AVG(rating) AS averageRating "
                + "FROM feedback WHERE restaurantId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getDouble("averageRating");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0.0;
    }
}

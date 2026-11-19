package com.tap.DAO;

import java.util.List;
import com.tap.Model.Feedback;

public interface FeedbackDAO {

    // Save customer feedback
    boolean addFeedback(Feedback feedback);

    // Check whether an order already has feedback
    boolean hasFeedbackForOrder(int orderId);

    // Get all feedback for a restaurant
    List<Feedback> getFeedbackByRestaurantId(int restaurantId);

    // Calculate the restaurant's average rating
    double getAverageRating(int restaurantId);
}

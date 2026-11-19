
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.tap.DAOimpl.RestaurantDAOImpl;
import com.tap.Model.Restaurant;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();

        // Fetch all restaurants from the database
        List<Restaurant> restaurantList =
                restaurantDAO.getAllRestaurants();

        // Debug message in Eclipse Console
        System.out.println(
                "Restaurants fetched: " + restaurantList.size()
        );

        // Send the list to index.jsp
        request.setAttribute("restaurants", restaurantList);

        // Forward the request to the homepage
        RequestDispatcher dispatcher =
                request.getRequestDispatcher("/index.jsp");

        dispatcher.forward(request, response);
    }
}

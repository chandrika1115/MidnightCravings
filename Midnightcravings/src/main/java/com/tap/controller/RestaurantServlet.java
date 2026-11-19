package com.tap.controller;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.tap.DAO.RestaurantDAO;
import com.tap.DAOimpl.RestaurantDAOImpl;
import com.tap.Model.Restaurant;

@WebServlet("/restaurants")
public class RestaurantServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException,IOException {
        
        RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
        List<Restaurant> restaurantList = restaurantDAO.getAllRestaurants();

        request.setAttribute("restaurantList", restaurantList);
        request.getRequestDispatcher("restaurant.jsp").forward(request, response);
    }
}
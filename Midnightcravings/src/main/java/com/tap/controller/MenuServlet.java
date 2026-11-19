package com.tap.controller; // Adjust package name as needed

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.tap.DAO.MenuDAO;
import com.tap.DAO.RestaurantDAO;
import com.tap.DAOimpl.MenuDAOImpl;             // Adjust import paths to match your project
import com.tap.DAOimpl.RestaurantDAOImpl;       // Adjust import paths to match your project
import com.tap.Model.Menu;
import com.tap.Model.Restaurant;

/**
 * Servlet handling request for displaying a restaurant's menu page.
 */
@WebServlet("/menu")
public class MenuServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String restaurantIdParam = request.getParameter("restaurantId");

        if (restaurantIdParam != null && !restaurantIdParam.trim().isEmpty()) {
            try {
                int restaurantId = Integer.parseInt(restaurantIdParam);

                // Instantiate DAO objects
                RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
                MenuDAO menuDAO = new MenuDAOImpl();

                // Fetch data from Database
                Restaurant restaurant = restaurantDAO.getRestaurant(restaurantId);
                List<Menu> menuList = menuDAO.getMenusByRestaurant(restaurantId);

                // Attach data to request object
                request.setAttribute("restaurant", restaurant);
                request.setAttribute("menuList", menuList);

                // Forward to menu.jsp
                request.getRequestDispatcher("menu.jsp").forward(request, response);
                return;

            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // If restaurantId is missing or invalid, redirect back to home page
        response.sendRedirect("home");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
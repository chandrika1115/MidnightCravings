package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.OrderDAO;
import com.tap.Model.Order;
import com.tap.utility.DBConnection;

public class OrderDAOImpl implements OrderDAO {

    public static final String INSERT_QUERY =
            "insert into orders(userId, restaurantId, orderDate, totalAmount, status, paymentMethod) "
            + "values(?,?,?,?,?,?)";

    public static final String SELECT_QUERY =
            "select * from orders where orderId=?";

    public static final String UPDATE_QUERY =
            "update orders set userId=?, restaurantId=?, orderDate=?, "
            + "totalAmount=?, status=?, paymentMethod=? where orderId=?";

    public static final String DELETE_QUERY =
            "delete from orders where orderId=?";

    public static final String SELECT_ALL_QUERY =
            "select * from orders";

    public static final String SELECT_BY_USER_QUERY =
            "select * from orders where userId=?";

    public static final String SELECT_BY_RESTAURANT_QUERY =
            "select * from orders where restaurantId=?";


    @Override
    public void addOrder(Order order) {

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(INSERT_QUERY);

            pstmt.setInt(1, order.getUserId());
            pstmt.setInt(2, order.getRestaurantId());
            pstmt.setTimestamp(3, order.getOrderDate());
            pstmt.setDouble(4, order.getTotalAmount());
            pstmt.setString(5, order.getStatus());
            pstmt.setString(6, order.getPaymentMethod());

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public Order getOrder(int orderId) {

        Order order = null;

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_QUERY);

            pstmt.setInt(1, orderId);

            ResultSet resultset = pstmt.executeQuery();

            if (resultset.next()) {
                order = extractOrderFromResultSet(resultset);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return order;
    }


    @Override
    public void updateOrder(Order order) {

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(UPDATE_QUERY);

            pstmt.setInt(1, order.getUserId());
            pstmt.setInt(2, order.getRestaurantId());
            pstmt.setTimestamp(3, order.getOrderDate());
            pstmt.setDouble(4, order.getTotalAmount());
            pstmt.setString(5, order.getStatus());
            pstmt.setString(6, order.getPaymentMethod());
            pstmt.setInt(7, order.getOrderId());

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void deleteOrder(int orderId) {

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(DELETE_QUERY);

            pstmt.setInt(1, orderId);

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public List<Order> getAllOrders() {

        List<Order> orderList = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_ALL_QUERY);

            ResultSet resultset = pstmt.executeQuery();

            while (resultset.next()) {

                Order order =
                        extractOrderFromResultSet(resultset);

                orderList.add(order);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderList;
    }


    @Override
    public List<Order> getOrdersByUser(int userId) {

        List<Order> orderList = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_BY_USER_QUERY);

            pstmt.setInt(1, userId);

            ResultSet resultset = pstmt.executeQuery();

            while (resultset.next()) {

                Order order =
                        extractOrderFromResultSet(resultset);

                orderList.add(order);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderList;
    }


    @Override
    public List<Order> getOrdersByRestaurant(int restaurantId) {

        List<Order> orderList = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_BY_RESTAURANT_QUERY);

            pstmt.setInt(1, restaurantId);

            ResultSet resultset = pstmt.executeQuery();

            while (resultset.next()) {

                Order order =
                        extractOrderFromResultSet(resultset);

                orderList.add(order);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderList;
    }


    private Order extractOrderFromResultSet(ResultSet result)
            throws SQLException {

        int orderId = result.getInt("orderId");
        int userId = result.getInt("userId");
        int restaurantId = result.getInt("restaurantId");
        Timestamp orderDate = result.getTimestamp("orderDate");
        double totalAmount = result.getDouble("totalAmount");
        String status = result.getString("status");
        String paymentMethod = result.getString("paymentMethod");

        return new Order(
                orderId,
                userId,
                restaurantId,
                orderDate,
                totalAmount,
                status,
                paymentMethod
        );
    }
}
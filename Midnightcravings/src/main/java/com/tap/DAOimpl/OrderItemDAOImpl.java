package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.OrderItemDAO;
import com.tap.Model.OrderItem;
import com.tap.utility.DBConnection;

public class OrderItemDAOImpl implements OrderItemDAO {

    public static final String INSERT_QUERY =
            "insert into orderitem(orderId, menuId, quantity, itemTotal) "
            + "values(?,?,?,?)";

    public static final String SELECT_QUERY =
            "select * from orderitem where orderItemId=?";

    public static final String UPDATE_QUERY =
            "update orderitem set orderId=?, menuId=?, quantity=?, "
            + "itemTotal=? where orderItemId=?";

    public static final String DELETE_QUERY =
            "delete from orderitem where orderItemId=?";

    public static final String SELECT_ALL_QUERY =
            "select * from orderitem";

    public static final String SELECT_BY_ORDER_QUERY =
            "select * from orderitem where orderId=?";


    @Override
    public void addOrderItem(OrderItem orderItem) {

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(INSERT_QUERY);

            pstmt.setInt(1, orderItem.getOrderId());
            pstmt.setInt(2, orderItem.getMenuId());
            pstmt.setInt(3, orderItem.getQuantity());
            pstmt.setDouble(4, orderItem.getItemTotal());

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public OrderItem getOrderItem(int orderItemId) {

        OrderItem orderItem = null;

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_QUERY);

            pstmt.setInt(1, orderItemId);

            ResultSet resultset = pstmt.executeQuery();

            if (resultset.next()) {
                orderItem = extractOrderItemFromResultSet(resultset);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItem;
    }


    @Override
    public void updateOrderItem(OrderItem orderItem) {

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(UPDATE_QUERY);

            pstmt.setInt(1, orderItem.getOrderId());
            pstmt.setInt(2, orderItem.getMenuId());
            pstmt.setInt(3, orderItem.getQuantity());
            pstmt.setDouble(4, orderItem.getItemTotal());
            pstmt.setInt(5, orderItem.getOrderItemId());

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void deleteOrderItem(int orderItemId) {

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(DELETE_QUERY);

            pstmt.setInt(1, orderItemId);

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public List<OrderItem> getAllOrderItems() {

        List<OrderItem> orderItemList = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_ALL_QUERY);

            ResultSet resultset = pstmt.executeQuery();

            while (resultset.next()) {

                OrderItem orderItem =
                        extractOrderItemFromResultSet(resultset);

                orderItemList.add(orderItem);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItemList;
    }


    @Override
    public List<OrderItem> getOrderItemsByOrder(int orderId) {

        List<OrderItem> orderItemList = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {
            PreparedStatement pstmt =
                    con.prepareStatement(SELECT_BY_ORDER_QUERY);

            pstmt.setInt(1, orderId);

            ResultSet resultset = pstmt.executeQuery();

            while (resultset.next()) {

                OrderItem orderItem =
                        extractOrderItemFromResultSet(resultset);

                orderItemList.add(orderItem);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItemList;
    }


    private OrderItem extractOrderItemFromResultSet(ResultSet result)
            throws SQLException {

        int orderItemId = result.getInt("orderItemId");
        int orderId = result.getInt("orderId");
        int menuId = result.getInt("menuId");
        int quantity = result.getInt("quantity");
        double itemTotal = result.getDouble("itemTotal");

        return new OrderItem(
                orderItemId,
                orderId,
                menuId,
                quantity,
                itemTotal);
     
    }
}
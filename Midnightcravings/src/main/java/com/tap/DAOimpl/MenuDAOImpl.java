package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.MenuDAO;
import com.tap.Model.Menu;
import com.tap.utility.DBConnection;

public class MenuDAOImpl implements MenuDAO {

    private static final String INSERT_QUERY =
            "INSERT INTO menu(restaurantId,itemName,description,price,available,imagePath)"
            + " values(?,?,?,?,?,?)";

    private static final String SELECT_QUERY =
            "select * from menu where menuId=?";

    private static final String UPDATE_QUERY =
            "update menu set restaurantId=?,itemName=?,description=?,price=?,available=?,imagePath=? "
            + "where menuId=?";

    private static final String DELETE_QUERY =
            "delete from menu where menuId=?";

    private static final String SELECT_ALL_QUERY =
            "select * from menu";

    private static final String SELECT =
            "select * from menu where restaurantId=?";


    @Override
    public void addMenu(Menu menu) {

        Connection con = DBConnection.getConnection();

        try {

            PreparedStatement pstmt =
                    con.prepareStatement(INSERT_QUERY, Statement.RETURN_GENERATED_KEYS);

            pstmt.setInt(1, menu.getRestaurantId());
            pstmt.setString(2, menu.getItemName());
            pstmt.setString(3, menu.getDescription());
            pstmt.setDouble(4, menu.getPrice());
            pstmt.setBoolean(5, menu.isAvailable());
            pstmt.setString(6, menu.getImagePath());

            int i = pstmt.executeUpdate();

            ResultSet rs = pstmt.getGeneratedKeys();

            if (rs.next()) {

                int menuId = rs.getInt(1);
                menu.setMenuId(menuId);
            }

            System.out.println(i + " row inserted");

        }
        catch (SQLException e) {

            e.printStackTrace();
        }
    }


    @Override
    public Menu getMenu(int menuId) {

        Menu menu = null;

        Connection con = DBConnection.getConnection();

        try {

            PreparedStatement pstmt = con.prepareStatement(SELECT_QUERY);

            pstmt.setInt(1, menuId);

            ResultSet resultset = pstmt.executeQuery();

            if (resultset.next()) {

                menu = extractMenuFromResultSet(resultset);
            }
        }
        catch (SQLException e) {

            e.printStackTrace();
        }

        return menu;
    }


    private Menu extractMenuFromResultSet(ResultSet res) throws SQLException {

        Menu menu = null;

        int menuId = res.getInt(1);

        int restaurantId = res.getInt(2);

        String itemName = res.getString(3);

        String description = res.getString(4);

        double price = res.getDouble(5);

        boolean available = res.getBoolean(6);

        String imagePath = res.getString(7);


        menu = new Menu(
                menuId,
                restaurantId,
                itemName,
                description,
                price,
                available,
                imagePath
        );

        return menu;
    }


    @Override
    public void updateMenu(Menu menu) {

        Connection con = DBConnection.getConnection();

        try {

            PreparedStatement pstmt = con.prepareStatement(UPDATE_QUERY);

            pstmt.setInt(1, menu.getRestaurantId());

            pstmt.setString(2, menu.getItemName());

            pstmt.setString(3, menu.getDescription());

            pstmt.setDouble(4, menu.getPrice());

            pstmt.setBoolean(5, menu.isAvailable());

            pstmt.setString(6, menu.getImagePath());

            pstmt.setInt(7, menu.getMenuId());

            pstmt.executeUpdate();
        }
        catch (SQLException e) {

            e.printStackTrace();
        }
    }


    @Override
    public void deleteMenu(int menuId) {

        Connection con = DBConnection.getConnection();

        try {

            PreparedStatement pstmt = con.prepareStatement(DELETE_QUERY);

            pstmt.setInt(1, menuId);

            pstmt.executeUpdate();

        }
        catch (SQLException e) {

            e.printStackTrace();
        }
    }


    @Override
    public List<Menu> getAllMenus() {

        Menu menu = null;

        ArrayList<Menu> allmenus = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {

            Statement stmt = con.createStatement();

            ResultSet res = stmt.executeQuery(SELECT_ALL_QUERY);

            while (res.next()) {

                menu = extractMenuFromResultSet(res);

                allmenus.add(menu);
            }
        }
        catch (SQLException e) {

            e.printStackTrace();
        }

        return allmenus;
    }


    @Override
    public List<Menu> getMenusByRestaurant(int restaurantId) {

        Menu menu = null;

        ArrayList<Menu> menuList = new ArrayList<>();

        Connection con = DBConnection.getConnection();

        try {

            PreparedStatement pstmt = con.prepareStatement(SELECT);

            pstmt.setInt(1, restaurantId);

            ResultSet res = pstmt.executeQuery();

            while (res.next()) {

                menu = extractMenuFromResultSet(res);

                menuList.add(menu);
            }
        }
        catch (SQLException e) {

            e.printStackTrace();
        }

        return menuList;
    }
}
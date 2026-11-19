package com.tap.DAOimpl;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import com.tap.DAO.RestaurantDAO;
import com.tap.Model.Restaurant;
import com.tap.utility.DBConnection;

public class RestaurantDAOImpl implements RestaurantDAO {
	public static final	String INSERT_QUERY = "INSERT INTO restaurant(name,address,phone,cuisineType,rating,openingTime,closingTime,active,imagePath) VALUES(?,?,?,?,?,?,?,?,?)";
public static final String SELECT_QUERY="select * from restaurant where restaurantid=?";
public static final String UPDATE_QUERY =
"update restaurant set name=?, address=?, phone=?, cuisineType=?, "
+ "rating=?, openingTime=?, closingTime=?, active=?, imagePath=? "
+ "where restaurantId=?";

public static final String DELETE_QUERY =
"delete from restaurant where restaurantId=?";

public static final String SELECT_ALL_QUERY =
"select * from restaurant";
	@Override
	public void addRestaurant(Restaurant res) {
	Connection connection=DBConnection.getConnection();
	try {
		PreparedStatement pstmt=connection.prepareStatement(INSERT_QUERY);
		pstmt.setString(1,res.getName());
		pstmt.setString(2, res.getAddress());
		pstmt.setString(3, res.getPhone());
		pstmt.setString(4, res.getCuisineType());
		pstmt.setDouble(5, res.getRating());
		pstmt.setTime(6, res.getOpeningTime());
		pstmt.setTime(7, res.getClosingTime());
		pstmt.setBoolean(8, res.isActive());
		pstmt.setString(9,res.getImagePath());
		pstmt.executeUpdate();
	}
	catch(Exception e) {
		e.printStackTrace();
	}
		
	}

	@Override
	public Restaurant getRestaurant(int restaurantId) {
		Restaurant res=null;
		Connection connection=DBConnection.getConnection();
		try{
			PreparedStatement pstmt=connection.prepareStatement(SELECT_QUERY);
			pstmt.setInt(1,restaurantId);
			ResultSet resultset=pstmt.executeQuery();
			if(resultset.next()) {
			res=extractRestaurantFromResultSet(resultset);
			}
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
		return res;
	}
		private Restaurant extractRestaurantFromResultSet(ResultSet result) throws SQLException {
			Restaurant res=null;
int restaurantId =result.getInt(1);
String name=result.getString(2);
String address=result.getString(3);
String phone=result.getString(4);
String cuisineType=result.getString(5);
double rating=result.getDouble(6);
 Time openingTime=result.getTime(7);
Time closingTime=result.getTime(8);
Boolean active=result.getBoolean(9);
String imagePath = result.getString(10);

res = new Restaurant(restaurantId, name, address, phone, cuisineType,
        rating, openingTime, closingTime, active, imagePath);
			 
			
			return res;
		}

	@Override
	public void updateRestaurant(Restaurant res) {
		Connection connection=DBConnection.getConnection();
		try {
		PreparedStatement pstmt=connection.prepareStatement(UPDATE_QUERY);
		pstmt.setString(1, res.getName());
		pstmt.setString(2, res.getAddress());
        pstmt.setString(3, res.getPhone());
        pstmt.setString(4, res.getCuisineType());
        pstmt.setDouble(5, res.getRating());
        pstmt.setTime(6, res.getOpeningTime());
        pstmt.setTime(7, res.getClosingTime());
        pstmt.setBoolean(8, res.isActive());
        pstmt.setString(9, res.getImagePath());
        pstmt.setInt(10, res.getRestaurantId());
       
        int i=pstmt.executeUpdate();
        System.out.println("rows updates"+i);
	}
		catch(SQLException e) {
			e.printStackTrace();
		}
	}
	@Override
	public void deleteRestaurant(int restaurantId) {
		Connection connection=DBConnection.getConnection();
		try {
		PreparedStatement pstmt=connection.prepareStatement(DELETE_QUERY);
		pstmt.setInt(1, restaurantId);
		int i=pstmt.executeUpdate();
		System.out.println(i+"rows deleted");
		
	}
		catch(SQLException e) {
			e.printStackTrace();
		}
	}
	@Override
	public List<Restaurant> getAllRestaurants() {

	    List<Restaurant> restaurantList = new ArrayList<>();

	    Connection connection = DBConnection.getConnection();

	    try {

	        Statement stmt = connection.createStatement();

	        ResultSet resultset = stmt.executeQuery("select * from restaurant");

	        while (resultset.next()) {

	            Restaurant res = extractRestaurantFromResultSet(resultset);

	            restaurantList.add(res);
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	    }

	    return restaurantList;
	}
}	
	

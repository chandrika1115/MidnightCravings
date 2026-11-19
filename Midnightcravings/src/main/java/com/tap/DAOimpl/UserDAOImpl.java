package com.tap.DAOimpl;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import com.tap.utility.DBConnection;
import com.tap.DAO.*;
import com.tap.Model.User;
public class UserDAOImpl implements UserDAO{

private static final String INSERT_QUERY="INSERT INTO user(username,password,email,address,"
				+"role,createDate,lastLoginDate)values(?,?,?,?,?,?,?)";
private static final String SELECT_QUERY="select * from user where userid=?";
private static final String UPDATE_QUERY="Update user set username=?,password=?,"
+"email=?,address=?,role=?,lastLoginDate=? where userid=?";
private static final String DELETE_QUERY="delete from user where userid=?";
private static final String SELECT_QUERY_ALL="select *from user";
	@Override
	public void addUser(User user) {
	Connection con=DBConnection.getConnection();
	try {
		PreparedStatement stmt=con.prepareStatement(INSERT_QUERY);
		stmt.setString(1,user.getUsername());
		stmt.setString(2, user.getPassword());
		stmt.setString(3, user.getEmail());
		stmt.setString(4, user.getAddress());
		stmt.setString(5, user.getRole());
		stmt.setTimestamp(6,new Timestamp(System.currentTimeMillis()) );
		stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
		int i=stmt.executeUpdate();
		System.out.println(i);
	}
	catch(SQLException e) {
		e.printStackTrace();
	}	
	}
@Override
	public User getUser(int userid) {
	User user=null;
	try {
	Connection connection=DBConnection.getConnection();
	PreparedStatement pstmt=connection.prepareStatement(SELECT_QUERY);
	pstmt.setInt(1,userid);
	ResultSet resultset=pstmt.executeQuery();
	user=extractUserFromResultSet(resultset);
	}
	catch(SQLException e)
	{
		e.printStackTrace();
	}
	
		return user;
	
	
}
private User extractUserFromResultSet(ResultSet res) throws SQLException {
	User user=null;
	int userid=res.getInt(1);
	String username=res.getString(2);
	String password=res.getString(3);
	String email=res.getString(4);
	String address=res.getString(5);
	 String role=res.getString(6);
	 Timestamp createDate=res.getTimestamp(7);
	 Timestamp lastLoginDate=res.getTimestamp(8);
	 user=new User(userid,username,password,email,address,role,createDate,lastLoginDate);
	
	return user;
}

	@Override
	public void updateUser(User user) {
		Connection connection=DBConnection.getConnection();
		try {
		PreparedStatement pstmt=connection.prepareStatement(UPDATE_QUERY);
		pstmt.setString(1,user.getUsername());
		pstmt.setString(2, user.getPassword());
		pstmt.setString(3, user.getEmail());
		pstmt.setString(4, user.getAddress());
		pstmt.setString(5, user.getRole());
		pstmt.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
		pstmt.setInt(7,user.getUserid());
		pstmt.executeUpdate();
	}
		catch(SQLException e)
		{
			e.printStackTrace();
		}
	}

	@Override
	public void deleteUser(int userid) {
	Connection connection=DBConnection.getConnection();
	try {
	PreparedStatement pstmt=connection.prepareStatement(DELETE_QUERY);
	pstmt.setInt(1,userid);
	pstmt.executeUpdate();
		
	}
	catch(SQLException e) {
		e.printStackTrace();
	}
	}
	@Override
	public List<User> getAllUsers() {
		ArrayList<User> alluser=new ArrayList();
		Connection connection=DBConnection.getConnection();
		try {
		Statement stmt	=connection.createStatement();
		ResultSet res=stmt.executeQuery(SELECT_QUERY_ALL);
		while(res.next()) {
			User user=extractUserFromResultSet(res);
			alluser.add(user);
		}
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}
		return alluser;
	}

}

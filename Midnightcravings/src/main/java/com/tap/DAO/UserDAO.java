package com.tap.DAO;
import java.util.List;

import com.tap.Model.User;
public interface UserDAO {
	
  void addUser(User user);
  User getUser(int userid);
  void updateUser(User user);
  void deleteUser(int userid);
  List<User> getAllUsers();
}

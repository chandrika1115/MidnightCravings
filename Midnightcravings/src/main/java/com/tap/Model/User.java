package com.tap.Model;

import java.sql.Timestamp;

public class User {
private int userid;
private String username;
private String password;
private String email;
private String address;
private String role;
private Timestamp createDate;
private Timestamp lastLoginDate;
public User()
{
	
}
public User(String username, String password, String email, String address, String role, Timestamp createDate,
		Timestamp lastLoginDate) {
	super();
	this.username = username;
	this.password = password;
	this.email = email;
	this.address = address;
	this.role = role;
	this.createDate = createDate;
	this.lastLoginDate = lastLoginDate;
}
@Override
public String toString() {
	return "User [userid=" + userid + ", username=" + username + ", password=" + password + ", email=" + email
			+ ", address=" + address + ", role=" + role + ", createDate=" + createDate + ", lastLoginDate="
			+ lastLoginDate + "]";
}
public User(String username, String password, String email, String address, String role) {
	super();
	this.username = username;
	this.password = password;
	this.email = email;
	this.address = address;
	this.role = role;
}
public int getUserid() {
	return userid;
}
public void setUserid(int userid) {
	this.userid = userid;
}
public User(int userid, String username, String password, String email, String address, String role,
		Timestamp createDate, Timestamp lastLoginDate) {
	super();
	this.userid = userid;
	this.username = username;
	this.password = password;
	this.email = email;
	this.address = address;
	this.role = role;
	this.createDate = createDate;
	this.lastLoginDate = lastLoginDate;
}
public String getUsername() {
	return username;
}
public void setUsername(String username) {
	this.username = username;
}
public String getPassword() {
	return password;
}
public void setPassword(String password) {
	this.password = password;
}
public String getEmail() {
	return email;
}
public void setEmail(String email) {
	this.email = email;
}
public String getAddress() {
	return address;
}
public void setAddress(String address) {
	this.address = address;
}
public String getRole() {
	return role;
}
public void setRole(String role) {
	this.role = role;
}
public Timestamp getCreateDate() {
	return createDate;
}
public void setCreateDate(Timestamp createDate) {
	this.createDate = createDate;
}
public Timestamp getLastLoginDate() {
	return lastLoginDate;
}
public void setLastLoginDate(Timestamp lastLoginDate) {
	this.lastLoginDate = lastLoginDate;
}
}


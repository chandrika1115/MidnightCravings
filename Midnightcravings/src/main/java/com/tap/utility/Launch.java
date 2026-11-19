package com.tap.utility;

import java.util.Scanner;

import com.tap.Model.User;
import com.tap.DAOimpl.*;
public class Launch {
public static void main(String[] args)
{
	Scanner sc=new Scanner(System.in);
	System.out.println("Enter the UserName");
	String username=sc.next();
	System.out.println("Enter the password");
	String password=sc.next();
	System.out.println("Enter the email");
	String email=sc.next();
	System.out.println("Enter the address");
	String address=sc.next();
	System.out.println("Enter the role");
	String role=sc.next();
	User u=new User(username,password,email,address,role,null,null);
	UserDAOImpl udao=new UserDAOImpl();
	udao.addUser(u);
	
}
}

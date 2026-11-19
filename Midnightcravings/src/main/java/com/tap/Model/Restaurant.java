package com.tap.Model;

import java.sql.Time;

public class Restaurant {
	private int restaurantId;
	private String name;
	private String address;
	private String phone;
	private String cuisineType;
	private double rating;
	private Time openingTime;
	private String imagePath;
	public Restaurant() {
		
	}
	public Restaurant(String name, String address, String phone, String cuisineType, double rating, Time openingTime,
			Time closingTime, boolean active ,String imagePath) {
		super();
		this.name = name;
		this.address = address;
		this.phone = phone;
		this.cuisineType = cuisineType;
		this.rating = rating;
		this.openingTime = openingTime;
		this.closingTime = closingTime;
		this.active = active;
		 this.imagePath=imagePath;
	}
	private Time closingTime;
	private boolean active;
	public Restaurant(int restaurantId, String name, String address, String phone, String cuisineType,
			double rating, Time openingTime, Time closingTime, Boolean active,String imagePath) {
     this.restaurantId=restaurantId;
     this.name=name;
     this.address=address;
     this.phone=phone;
     this.cuisineType=cuisineType;
     this.rating=rating;
     this.openingTime=openingTime;
     this.closingTime=closingTime;
     this.active=active;
     this.imagePath=imagePath;
	}

	@Override
	public String toString() {
		return "Restaurant [restaurantId=" + restaurantId + ", name=" + name + ", address=" + address + ", phone="
				+ phone + ", cuisineType=" + cuisineType + ", rating=" + rating + ", openingTime=" + openingTime
				+ ", closingTime=" + closingTime + ", active=" + active +",imagePath="+imagePath+ "]";
	}

	public int getRestaurantId() {
		return restaurantId;
	}
	public void setRestaurantId(int restaurantId) {
		this.restaurantId = restaurantId;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getCuisineType() {
		return cuisineType;
	}
	public void setCuisineType(String cuisineType) {
		this.cuisineType = cuisineType;
	}
	public double getRating() {
		return rating;
	}
	public void setRating(double rating) {
		this.rating = rating;
	}
	public Time getOpeningTime() {
		return openingTime;
	}
	public void setOpeningTime(Time openingTime) {
		this.openingTime = openingTime;
	}
	public Time getClosingTime() {
		return closingTime;
	}
	public void setClosingTime(Time closingTime) {
		this.closingTime = closingTime;
	}
	public boolean isActive() {
		return active;
	}
	public void setActive(boolean active) {
		this.active = active;
	}
	public String getImagePath() {
	    return imagePath;
	}

	public void setImagePath(String imagePath) {
	    this.imagePath = imagePath;
	}


}

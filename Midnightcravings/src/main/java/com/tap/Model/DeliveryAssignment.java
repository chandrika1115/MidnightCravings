
package com.tap.Model;

public class DeliveryAssignment {

    private int assignmentId;
    private int orderId;
    private int deliveryAgentId;
    private String deliveryStatus;

    public DeliveryAssignment() {
    }

    public DeliveryAssignment(
            int assignmentId,
            int orderId,
            int deliveryAgentId,
            String deliveryStatus) {

        this.assignmentId = assignmentId;
        this.orderId = orderId;
        this.deliveryAgentId = deliveryAgentId;
        this.deliveryStatus = deliveryStatus;
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getDeliveryAgentId() {
        return deliveryAgentId;
    }

    public void setDeliveryAgentId(int deliveryAgentId) {
        this.deliveryAgentId = deliveryAgentId;
    }

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }
}

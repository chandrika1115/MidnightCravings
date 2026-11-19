
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,com.tap.Model.RestaurantOrder,com.tap.Model.RestaurantOrderItem" %>

<%
    if (session.getAttribute("userId") == null ||
        !"restaurant".equalsIgnoreCase(
            (String) session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<RestaurantOrder> orders =
        (List<RestaurantOrder>) request.getAttribute("orders");

    String contextPath = request.getContextPath();
    String updated = request.getParameter("updated");
    String assignment = request.getParameter("assignment");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Incoming Orders | Midnight Cravings</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    padding: 30px;
    font-family: Arial, sans-serif;
    background: #FFFDF7;
    color: #29251C;
}

.header {
    background: #FFC025;
    padding: 22px;
    border-radius: 14px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 18px;
    flex-wrap: wrap;
}

.header-content { flex: 1; min-width: 200px; }
.header h1 { margin-top: 0; margin-bottom: 10px; }
.header p { margin-bottom: 0; line-height: 1.5; }
.logout-form { margin: 0; }

.logout-btn {
    padding: 10px 17px;
    background: #FFFFFF;
    color: #29251C;
    border: 2px solid #FFC025;
    border-radius: 10px;
    font: bold 13px Arial, sans-serif;
    cursor: pointer;
}

.logout-btn:hover { background: #FFF3C8; }

.back {
    display: inline-block;
    margin-top: 15px;
    color: #29251C;
    text-decoration: none;
    font-weight: bold;
}

.back:hover { text-decoration: underline; }

.notice {
    margin-top: 20px;
    padding: 14px 17px;
    border-radius: 10px;
    line-height: 1.5;
    background: #FFF3C4;
    border: 1px solid #E5B62D;
}

.notice.error {
    background: #FCEAE5;
    border-color: #D9A69B;
    color: #8D2922;
}

.order {
    background: #FFFFFF;
    border: 1.5px solid #FFC025;
    border-radius: 16px;
    padding: 22px;
    margin-top: 20px;
    box-shadow: 0 4px 14px rgba(41,37,28,.05);
}

.order h2 { margin-top: 0; font-size: 22px; }
.order h3 { margin-top: 22px; }

.order > p {
    color: #6B6559;
    line-height: 1.6;
    overflow-wrap: anywhere;
}

.status { color: #29251C; font-weight: bold; }

.item {
    padding: 12px;
    margin: 8px 0;
    background: #FFFDF7;
    border: 1px solid #F0E8D5;
    border-radius: 10px;
    overflow-wrap: anywhere;
}

.item p { margin: 6px 0; color: #6B6559; font-size: 14px; }

.order-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin-top: 20px;
}

.order-actions form { margin: 0; }

.accept-btn, .reject-btn {
    border-radius: 10px;
    padding: 11px 20px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
}

.accept-btn {
    background: #FFC025;
    color: #29251C;
    border: 1px solid #FFC025;
}

.accept-btn:hover { background: #F0B000; }

.reject-btn {
    background: #FFFDF7;
    color: #A52A2A;
    border: 1px solid #D9B7A8;
}

.reject-btn:hover { background: #FCEAE5; }

.modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    padding: 20px;
    background: rgba(25,23,19,.58);
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.modal-overlay.show { display: flex; }

.confirm-modal, .logout-modal-content {
    width: 100%;
    max-width: 420px;
    background: #FFFDF7;
    border: 1px solid #F0E8D5;
    border-radius: 20px;
    padding: 28px;
    box-shadow: 0 20px 60px rgba(0,0,0,.2);
}

.confirm-modal h2, .logout-modal-content h2 { margin-top: 0; }
.confirm-modal p, .logout-modal-content p {
    color: #746E63;
    font-size: 14px;
    line-height: 1.7;
}

.modal-actions, .logout-modal-actions {
    display: flex;
    gap: 12px;
    margin-top: 20px;
}

.modal-btn, .cancel-btn, .confirm-logout-btn {
    flex: 1;
    min-height: 44px;
    padding: 12px 14px;
    border-radius: 10px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
}

.keep-btn, .cancel-btn {
    background: #FFFFFF;
    color: #29251C;
    border: 1px solid #DED9CE;
}

.confirm-reject-btn {
    background: #C83D32;
    color: #FFFFFF;
    border: 1px solid #C83D32;
}

.confirm-logout-btn {
    background: #FFC025;
    color: #29251C;
    border: 1px solid #FFC025;
}

.confirm-reject-btn:disabled { opacity: .7; cursor: wait; }

.logout-modal-content { text-align: center; }
.logout-icon {
    font-size: 29px;
    margin-bottom: 14px;
}

@media (max-width: 600px) {
    body { padding: 15px; }
    .header { align-items: stretch; }
    .logout-btn { width: 100%; }
    .order { padding: 16px; }
    .confirm-modal, .logout-modal-content { padding: 23px; }
    .modal-actions, .logout-modal-actions { flex-direction: column; }
    .modal-btn, .cancel-btn, .confirm-logout-btn { width: 100%; }
}
</style>
</head>

<body>

<div class="header">
    <div class="header-content">
        <h1>Incoming Orders</h1>
        <p>Review and manage orders placed at your restaurant.</p>
    </div>

    <form class="logout-form" id="logoutForm"
          action="<%= contextPath %>/logout" method="post">
        <button type="button" class="logout-btn"
                onclick="openLogoutModal()">Logout</button>
    </form>
</div>

<a class="back" href="<%= contextPath %>/restaurant-dashboard">
    &larr; Back to Dashboard
</a>

<% if ("success".equals(updated) && "pending".equals(assignment)) { %>
    <div class="notice">
        Order status updated to Ready for Pickup. No delivery agent is
        currently available, so the order still needs an assignment.
    </div>
<% } else if ("success".equals(updated)) { %>
    <div class="notice">
        Order status updated successfully.
    </div>
<% } %>

<% if ("notupdated".equals(error)) { %>
    <div class="notice error">
        The order could not be updated. It may already have changed status,
        or it may not belong to your restaurant. Refresh the order list.
    </div>
<% } %>

<% if (orders == null || orders.isEmpty()) { %>

    <div class="order">
        <h2>No orders yet</h2>
        <p>New customer orders will appear here.</p>
    </div>

<% } else {
    for (RestaurantOrder order : orders) { %>

    <div class="order">
        <h2>Order #<%= order.getOrderId() %></h2>

        <p>Customer: <%= order.getCustomerName() %></p>
        <p>Date: <%= order.getOrderDate() %></p>
        <p>Status: <span class="status"><%= order.getStatus() %></span></p>
        <p>Payment: <%= order.getPaymentMethod() %></p>
        <p>Delivery address: <%= order.getDeliveryAddress() %></p>

        <h3>Items</h3>

        <% for (RestaurantOrderItem item : order.getItems()) { %>
            <div class="item">
                <strong><%= item.getItemName() %></strong>
                <p>Quantity: <%= item.getQuantity() %></p>
                <p>Item total: ₹<%= item.getItemTotal() %></p>
            </div>
        <% } %>

        <h3>Order total: ₹<%= order.getTotalAmount() %></h3>

        <% if ("Pending".equalsIgnoreCase(order.getStatus())) { %>
            <div class="order-actions">
                <form method="post"
                      action="<%= contextPath %>/update-order-status">
                    <input type="hidden" name="orderId"
                           value="<%= order.getOrderId() %>">
                    <input type="hidden" name="action" value="accept">
                    <button type="submit" class="accept-btn">Accept Order</button>
                </form>

                <form method="post"
                      action="<%= contextPath %>/update-order-status"
                      class="reject-form">
                    <input type="hidden" name="orderId"
                           value="<%= order.getOrderId() %>">
                    <input type="hidden" name="action" value="reject">
                    <button type="button" class="reject-btn"
                            onclick="openRejectModal(this.form)">
                        Reject Order
                    </button>
                </form>
            </div>

        <% } else if ("Confirmed".equalsIgnoreCase(order.getStatus())) { %>
            <div class="order-actions">
                <form method="post"
                      action="<%= contextPath %>/update-order-status">
                    <input type="hidden" name="orderId"
                           value="<%= order.getOrderId() %>">
                    <input type="hidden" name="action" value="prepare">
                    <button type="submit" class="accept-btn">
                        Start Preparing
                    </button>
                </form>
            </div>

        <% } else if ("Preparing".equalsIgnoreCase(order.getStatus())) { %>
            <div class="order-actions">
                <form method="post"
                      action="<%= contextPath %>/update-order-status">
                    <input type="hidden" name="orderId"
                           value="<%= order.getOrderId() %>">
                    <input type="hidden" name="action" value="ready">
                    <button type="submit" class="accept-btn">
                        Ready for Pickup
                    </button>
                </form>
            </div>

        <% } else if ("Ready for Pickup".equalsIgnoreCase(order.getStatus())) { %>
            <p class="status">
                Order is ready. Waiting for the delivery agent to pick it up.
            </p>

        <% } else if ("Picked Up".equalsIgnoreCase(order.getStatus()) ||
                     "Out for Delivery".equalsIgnoreCase(order.getStatus())) { %>
            <p class="status">The delivery agent is handling this order.</p>

        <% } else if ("Delivered".equalsIgnoreCase(order.getStatus())) { %>
            <p class="status">Order successfully delivered.</p>

        <% } else if ("Rejected".equalsIgnoreCase(order.getStatus())) { %>
            <p class="status">This order has been rejected.</p>
        <% } %>
    </div>

<%  }
   }
%>

<div id="rejectModal" class="modal-overlay"
     onclick="handleOverlayClick(event)">
    <div class="confirm-modal" role="dialog" aria-modal="true"
         aria-labelledby="rejectTitle">
        <h2 id="rejectTitle">Reject this order?</h2>
        <p>Are you sure you want to reject this order?</p>
        <div class="modal-actions">
            <button type="button" class="modal-btn keep-btn"
                    onclick="closeRejectModal()">Keep Order</button>
            <button type="button" id="confirmRejectBtn"
                    class="modal-btn confirm-reject-btn"
                    onclick="confirmReject()">Yes, Reject</button>
        </div>
    </div>
</div>

<div id="logoutModal" class="modal-overlay"
     onclick="handleLogoutOverlayClick(event)">
    <div class="logout-modal-content" role="dialog" aria-modal="true"
         aria-labelledby="logoutTitle">
        <div class="logout-icon" aria-hidden="true">↗</div>
        <h2 id="logoutTitle">Leaving so soon?</h2>
        <p>Are you sure you want to logout from Midnight Cravings?</p>
        <div class="logout-modal-actions">
            <button type="button" class="cancel-btn"
                    onclick="closeLogoutModal()">Cancel</button>
            <button type="button" class="confirm-logout-btn"
                    onclick="confirmLogout()">Yes, Logout</button>
        </div>
    </div>
</div>

<script>
let pendingRejectForm = null;
const rejectModal = document.getElementById("rejectModal");
const logoutModal = document.getElementById("logoutModal");
const confirmRejectBtn = document.getElementById("confirmRejectBtn");

function openRejectModal(form) {
    pendingRejectForm = form;
    rejectModal.classList.add("show");
    document.body.style.overflow = "hidden";
    confirmRejectBtn.disabled = false;
    confirmRejectBtn.textContent = "Yes, Reject";
    confirmRejectBtn.focus();
}

function closeRejectModal() {
    rejectModal.classList.remove("show");
    document.body.style.overflow = "";
    pendingRejectForm = null;
}

function confirmReject() {
    if (!pendingRejectForm) return;
    confirmRejectBtn.disabled = true;
    confirmRejectBtn.textContent = "Rejecting...";
    pendingRejectForm.submit();
}

function handleOverlayClick(event) {
    if (event.target === rejectModal) closeRejectModal();
}

function openLogoutModal() {
    logoutModal.classList.add("show");
    document.body.style.overflow = "hidden";
}

function closeLogoutModal() {
    logoutModal.classList.remove("show");
    document.body.style.overflow = "";
}

function confirmLogout() {
    document.getElementById("logoutForm").submit();
}

function handleLogoutOverlayClick(event) {
    if (event.target === logoutModal) closeLogoutModal();
}

document.addEventListener("keydown", function(event) {
    if (event.key === "Escape") {
        if (logoutModal.classList.contains("show")) {
            closeLogoutModal();
        } else if (rejectModal.classList.contains("show")) {
            closeRejectModal();
        }
    }
});
</script>

</body>
</html>

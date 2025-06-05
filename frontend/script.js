// Wait for the DOM to be fully loaded
document.addEventListener("DOMContentLoaded", function () {
  // Get form and response elements
  const form = document.getElementById("travelContactForm");
  const responseMessage = document.getElementById("responseMessage");
  const responseTitle = document.getElementById("responseTitle");
  const responseText = document.getElementById("responseText");
  const closeBtn = document.querySelector(".close-btn");

  // API Gateway endpoint - This should be set via environment variable or build process
  // For local development, you can temporarily set this to your API Gateway URL
  // In production, this should be injected during the build/deployment process
  const API_ENDPOINT = window.API_ENDPOINT || "your-api-gateway-endpoint-here";

  // Check if API endpoint is configured
  if (API_ENDPOINT === "your-api-gateway-endpoint-here") {
    console.warn(
      "API_ENDPOINT not configured. Please set the API Gateway URL."
    );
  }

  // Form submission handler
  form.addEventListener("submit", function (event) {
    // Prevent the default form submission
    event.preventDefault();

    // Basic form validation
    if (!validateForm()) {
      return false;
    }

    // Submit form data to API
    submitFormToAPI();
  });

  // Close button for response message
  closeBtn.addEventListener("click", function () {
    responseMessage.classList.add("hidden");
  });

  // Form validation function
  function validateForm() {
    let isValid = true;

    // Get form fields
    const name = document.getElementById("name");
    const email = document.getElementById("email");

    // Reset previous error states
    resetErrorStates();

    // Validate name
    if (!name.value.trim()) {
      setErrorFor(name, "Name is required");
      isValid = false;
    }

    // Validate email
    if (!email.value.trim()) {
      setErrorFor(email, "Email is required");
      isValid = false;
    } else if (!isValidEmail(email.value)) {
      setErrorFor(email, "Please enter a valid email address");
      isValid = false;
    }

    return isValid;
  }

  // Helper function to set error state for a field
  function setErrorFor(input, message) {
    const formGroup = input.parentElement;

    // Add error class
    formGroup.classList.add("error");

    // Create error message element if it doesn't exist
    let errorMessage = formGroup.querySelector(".error-message");
    if (!errorMessage) {
      errorMessage = document.createElement("span");
      errorMessage.className = "error-message";
      formGroup.appendChild(errorMessage);
    }

    // Set error message
    errorMessage.innerText = message;
    errorMessage.style.color = "#e74c3c";
    errorMessage.style.fontSize = "0.8rem";
    errorMessage.style.marginTop = "0.25rem";
    errorMessage.style.display = "block";
  }

  // Helper function to reset error states
  function resetErrorStates() {
    // Remove all error messages
    const errorMessages = document.querySelectorAll(".error-message");
    errorMessages.forEach(function (message) {
      message.remove();
    });

    // Remove error class from form groups
    const formGroups = document.querySelectorAll(".form-group");
    formGroups.forEach(function (group) {
      group.classList.remove("error");
    });
  }

  // Helper function to validate email format
  function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  // Function to submit form data to API
  function submitFormToAPI() {
    // Disable submit button and show loading state
    const submitBtn = document.getElementById("submitBtn");
    const originalBtnText = submitBtn.innerText;
    submitBtn.disabled = true;
    submitBtn.innerText = "Submitting...";

    // Collect form data
    const formData = {
      name: document.getElementById("name").value,
      email: document.getElementById("email").value,
      phone: document.getElementById("phone").value,
      destination: document.getElementById("destination").value,
      travelDateStart: document.getElementById("travelDateStart").value,
      travelDateEnd: document.getElementById("travelDateEnd").value,
      travelers: document.getElementById("travelers").value,
      message: document.getElementById("message").value,
    };

    // Send the data to the API
    fetch(API_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(formData),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        // Show success message
        responseMessage.classList.remove("hidden");
        responseMessage.querySelector(".response-content").className =
          "response-content success";
        responseTitle.innerText = "Thank You!";
        responseText.innerText = `Thank you, ${formData.name}! Your travel inquiry has been submitted successfully with reference number: ${data.submissionId}. We'll contact you shortly at ${formData.email}.`;

        // Reset form
        form.reset();
      })
      .catch((error) => {
        // Show error message
        responseMessage.classList.remove("hidden");
        responseMessage.querySelector(".response-content").className =
          "response-content error";
        responseTitle.innerText = "Submission Error";
        responseText.innerText =
          "We encountered an error while submitting your inquiry. Please try again later or contact us directly.";

        console.error("Error submitting form:", error);
      })
      .finally(() => {
        // Reset button state
        submitBtn.disabled = false;
        submitBtn.innerText = originalBtnText;
      });
  }
});

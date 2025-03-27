// Wait for the DOM to be fully loaded
document.addEventListener("DOMContentLoaded", function () {
  // Get form and response elements
  const form = document.getElementById("travelContactForm");
  const responseMessage = document.getElementById("responseMessage");
  const responseTitle = document.getElementById("responseTitle");
  const responseText = document.getElementById("responseText");
  const closeBtn = document.querySelector(".close-btn");

  // Form submission handler
  form.addEventListener("submit", function (event) {
    // Prevent the default form submission
    event.preventDefault();

    // Basic form validation
    if (!validateForm()) {
      return false;
    }

    // In a real implementation, you would send the form data to your API Gateway here
    // For the demo, we'll simulate a successful submission
    simulateFormSubmission();
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

  // Simulate form submission (in a real app, this would be an API call)
  function simulateFormSubmission() {
    // Disable submit button and show loading state
    const submitBtn = document.getElementById("submitBtn");
    const originalBtnText = submitBtn.innerText;
    submitBtn.disabled = true;
    submitBtn.innerText = "Submitting...";

    // Simulate network delay
    setTimeout(function () {
      // Get form data for demonstration purposes
      const formData = new FormData(form);
      const formObject = {};

      formData.forEach(function (value, key) {
        formObject[key] = value;
      });

      // For demo purposes only - log the data that would be sent
      console.log("Form data that would be sent to API:", formObject);

      // Show success message
      responseMessage.classList.remove("hidden");
      responseMessage.querySelector(".response-content").className =
        "response-content success";
      responseTitle.innerText = "Thank You!";
      responseText.innerText = `Thank you, ${formObject.name}! Your travel inquiry has been submitted successfully. We'll contact you shortly at ${formObject.email}.`;

      // Reset form
      form.reset();

      // Reset button state
      submitBtn.disabled = false;
      submitBtn.innerText = originalBtnText;
    }, 1500);
  }

  // Handle error scenarios (for demo purposes)
  window.simulateError = function () {
    responseMessage.classList.remove("hidden");
    responseMessage.querySelector(".response-content").className =
      "response-content error";
    responseTitle.innerText = "Submission Error";
    responseText.innerText =
      "We encountered an error while submitting your inquiry. Please try again later or contact us directly.";
  };
});

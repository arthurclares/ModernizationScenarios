// LEGACY PATTERN: Plain JavaScript without module system
// MODERNIZATION PATH: ES6 modules, TypeScript, or modern bundlers (Webpack, Vite)

/*
 * Site-wide JavaScript for PizzaShop.WebForms
 * This file contains client-side enhancements for the legacy ASP.NET Web Forms application
 * 
 * LEGACY PATTERNS USED:
 * - jQuery 2.2.4 for DOM manipulation
 * - Global function declarations
 * - Direct DOM manipulation
 * - No build process or bundling
 * 
 * MODERNIZATION PATH:
 * - Use modern JavaScript (ES6+)
 * - Implement module system
 * - Use build tools (webpack, esbuild)
 * - Consider TypeScript for type safety
 * - Replace with Blazor WebAssembly for interactive features
 */

$(document).ready(function () {
    // LEGACY PATTERN: jQuery document ready
    // MODERNIZATION NOTE: Use DOMContentLoaded or framework lifecycle methods
    
    initializeTooltips();
    initializeSmoothScroll();
    initializeFormValidation();
    
    // Show success message if added to cart
    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('added') === '1') {
        showCartAddedNotification();
    }
});

// Initialize Bootstrap tooltips
// LEGACY PATTERN: Bootstrap 3.x tooltip initialization
function initializeTooltips() {
    if (typeof $().tooltip === 'function') {
        $('[data-toggle="tooltip"]').tooltip();
    }
}

// Smooth scroll for anchor links
// LEGACY PATTERN: jQuery animate for smooth scrolling
// MODERNIZATION PATH: CSS scroll-behavior: smooth
function initializeSmoothScroll() {
    $('a[href^="#"]').on('click', function (e) {
        var target = $(this.hash);
        if (target.length) {
            e.preventDefault();
            $('html, body').animate({
                scrollTop: target.offset().top - 70
            }, 500);
        }
    });
}

// Form validation enhancements
// LEGACY PATTERN: Client-side validation with jQuery
// MODERNIZATION PATH: HTML5 validation or framework validation
function initializeFormValidation() {
    // Add custom CSS classes for validation states
    $('.form-control').on('blur', function () {
        if ($(this).val().trim() === '' && $(this).prop('required')) {
            $(this).addClass('has-error');
        } else {
            $(this).removeClass('has-error');
        }
    });
}

// Show notification when item added to cart
// LEGACY PATTERN: jQuery fadeIn/fadeOut animations
// MODERNIZATION PATH: CSS transitions/animations or toast library
function showCartAddedNotification() {
    var notification = $('<div class="cart-notification">')
        .text('Item added to cart!')
        .appendTo('body')
        .fadeIn(300);
    
    setTimeout(function () {
        notification.fadeOut(300, function () {
            $(this).remove();
        });
        
        // Remove URL parameter
        // LEGACY PATTERN: Direct URL manipulation
        // MODERNIZATION PATH: Client-side routing with SPA framework
        if (history.replaceState) {
            var cleanUrl = window.location.pathname;
            history.replaceState({}, document.title, cleanUrl);
        }
    }, 2000);
}

// Add CSS for notification
// LEGACY PATTERN: Inline style injection
// MODERNIZATION PATH: CSS modules or styled components
var notificationStyle = '<style>' +
    '.cart-notification {' +
    '    position: fixed;' +
    '    top: 80px;' +
    '    right: 20px;' +
    '    background-color: #4caf50;' +
    '    color: white;' +
    '    padding: 15px 25px;' +
    '    border-radius: 4px;' +
    '    box-shadow: 0 4px 6px rgba(0,0,0,0.2);' +
    '    z-index: 9999;' +
    '    display: none;' +
    '    font-weight: bold;' +
    '}' +
    '</style>';
$('head').append(notificationStyle);

// LEGACY PATTERN: Global namespace pollution
// MODERNIZATION NOTE: Use IIFE or modules to avoid global variables
// MODERNIZATION PATH:
// - Convert to ES6 modules
// - Use strict mode
// - Implement proper module bundling
// - Consider replacing with modern framework (React, Vue, Blazor)

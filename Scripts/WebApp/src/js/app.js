/**
 * ============================================================================
 * TaskMaster Classic - Legacy JavaScript Application
 * ============================================================================
 * 
 * MODERNIZATION NOTES:
 * This application intentionally uses legacy JavaScript patterns to serve as
 * a modernization exercise. The following outdated patterns are used:
 * 
 * 1. var instead of let/const (ES5)
 * 2. jQuery 2.x for DOM manipulation
 * 3. Callback-based async patterns (callback hell)
 * 4. IIFE pattern instead of ES6 modules
 * 5. String concatenation instead of template literals
 * 6. function declarations instead of arrow functions
 * 7. No proper state management
 * 8. Global namespace pollution
 * 9. No error boundaries or proper error handling
 * 10. Manual DOM manipulation instead of virtual DOM
 * 
 * FUTURE MODERNIZATION PATH:
 * - Migrate to vanilla JavaScript ES6+ or React/Vue
 * - Use const/let instead of var
 * - Implement async/await for asynchronous operations
 * - Add proper module bundling (Webpack/Vite)
 * - Implement TypeScript for type safety
 * - Use modern state management (Redux, Zustand, or React Context)
 * 
 * ============================================================================
 */

// IIFE to avoid polluting global namespace (legacy pattern)
var TaskManager = (function($) {
    'use strict';

    // ========================================================================
    // Configuration
    // ========================================================================
    var CONFIG = {
        STORAGE_KEY: 'taskmaster_tasks',
        DATE_FORMAT: 'short',
        ANIMATION_DURATION: 300
    };

    // ========================================================================
    // Sample Data - Pre-populated tasks for demonstration
    // ========================================================================
    var SAMPLE_TASKS = [
        {
            id: 'task_1',
            title: 'Complete quarterly report',
            description: 'Prepare and submit the Q4 financial report to the management team',
            priority: 'high',
            completed: false,
            createdAt: new Date(2026, 0, 15, 9, 0).toISOString()
        },
        {
            id: 'task_2',
            title: 'Review pull requests',
            description: 'Check and approve pending code reviews on GitHub',
            priority: 'medium',
            completed: false,
            createdAt: new Date(2026, 0, 18, 14, 30).toISOString()
        },
        {
            id: 'task_3',
            title: 'Buy groceries',
            description: 'Milk, bread, eggs, vegetables, and fruits for the week',
            priority: 'low',
            completed: true,
            createdAt: new Date(2026, 0, 19, 10, 0).toISOString()
        },
        {
            id: 'task_4',
            title: 'Schedule dentist appointment',
            description: 'Call Dr. Smith office for annual checkup',
            priority: 'medium',
            completed: false,
            createdAt: new Date(2026, 0, 20, 8, 0).toISOString()
        },
        {
            id: 'task_5',
            title: 'Modernize legacy JavaScript app',
            description: 'Migrate TaskMaster from jQuery/ES5 to React with TypeScript',
            priority: 'high',
            completed: false,
            createdAt: new Date(2026, 0, 21, 11, 0).toISOString()
        }
    ];

    // ========================================================================
    // State Management (simple object-based - legacy pattern)
    // ========================================================================
    var state = {
        tasks: [],
        filter: 'all',
        searchTerm: ''
    };

    // ========================================================================
    // Utility Functions
    // ========================================================================
    
    /**
     * Generate unique ID (legacy approach - not using crypto.randomUUID())
     * @returns {string} Unique identifier
     */
    function generateId() {
        // Legacy pattern: using timestamp + random number
        return 'task_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    /**
     * Format date for display (legacy approach)
     * @param {string} dateString - ISO date string
     * @returns {string} Formatted date
     */
    function formatDate(dateString) {
        var date = new Date(dateString);
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        var month = months[date.getMonth()];
        var day = date.getDate();
        var year = date.getFullYear();
        var hours = date.getHours();
        var minutes = date.getMinutes();
        
        // Legacy padding approach
        var paddedMinutes = minutes < 10 ? '0' + minutes : minutes;
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;
        
        return month + ' ' + day + ', ' + year + ' at ' + hours + ':' + paddedMinutes + ' ' + ampm;
    }

    /**
     * Escape HTML to prevent XSS (legacy approach)
     * @param {string} text - Text to escape
     * @returns {string} Escaped text
     */
    function escapeHtml(text) {
        if (!text) return '';
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // ========================================================================
    // Storage Functions (using localStorage)
    // ========================================================================
    
    /**
     * Load tasks from localStorage
     * Uses callback pattern (legacy)
     * @param {function} callback - Callback function
     */
    function loadTasks(callback) {
        // Simulate async operation with setTimeout (legacy pattern)
        setTimeout(function() {
            try {
                var stored = localStorage.getItem(CONFIG.STORAGE_KEY);
                if (stored) {
                    state.tasks = JSON.parse(stored);
                } else {
                    // Load sample data if no tasks exist
                    state.tasks = SAMPLE_TASKS.slice(); // Clone array
                    saveTasks(function() {
                        console.log('[TaskManager] Sample tasks loaded');
                    });
                }
                if (typeof callback === 'function') {
                    callback(null, state.tasks);
                }
            } catch (e) {
                console.error('[TaskManager] Error loading tasks:', e);
                state.tasks = SAMPLE_TASKS.slice();
                if (typeof callback === 'function') {
                    callback(e, null);
                }
            }
        }, 100);
    }

    /**
     * Save tasks to localStorage
     * Uses callback pattern (legacy)
     * @param {function} callback - Callback function
     */
    function saveTasks(callback) {
        // Simulate async operation (legacy pattern)
        setTimeout(function() {
            try {
                localStorage.setItem(CONFIG.STORAGE_KEY, JSON.stringify(state.tasks));
                if (typeof callback === 'function') {
                    callback(null);
                }
            } catch (e) {
                console.error('[TaskManager] Error saving tasks:', e);
                if (typeof callback === 'function') {
                    callback(e);
                }
            }
        }, 50);
    }

    // ========================================================================
    // Task CRUD Operations
    // ========================================================================
    
    /**
     * Add a new task
     * @param {object} taskData - Task data
     * @param {function} callback - Callback function
     */
    function addTask(taskData, callback) {
        var task = {
            id: generateId(),
            title: taskData.title,
            description: taskData.description || '',
            priority: taskData.priority || 'medium',
            completed: false,
            createdAt: new Date().toISOString()
        };
        
        state.tasks.unshift(task); // Add to beginning
        
        // Nested callback (callback hell - legacy pattern)
        saveTasks(function(err) {
            if (err) {
                callback(err, null);
                return;
            }
            updateTaskCounts(function() {
                renderTasks(function() {
                    callback(null, task);
                });
            });
        });
    }

    /**
     * Update an existing task
     * @param {string} taskId - Task ID
     * @param {object} updates - Updates to apply
     * @param {function} callback - Callback function
     */
    function updateTask(taskId, updates, callback) {
        var taskIndex = -1;
        
        // Legacy for loop instead of findIndex
        for (var i = 0; i < state.tasks.length; i++) {
            if (state.tasks[i].id === taskId) {
                taskIndex = i;
                break;
            }
        }
        
        if (taskIndex === -1) {
            callback(new Error('Task not found'), null);
            return;
        }
        
        // Legacy object merge (no Object.assign or spread)
        var task = state.tasks[taskIndex];
        for (var key in updates) {
            if (updates.hasOwnProperty(key)) {
                task[key] = updates[key];
            }
        }
        
        // Callback chain (legacy pattern)
        saveTasks(function(err) {
            if (err) {
                callback(err, null);
                return;
            }
            updateTaskCounts(function() {
                renderTasks(function() {
                    callback(null, task);
                });
            });
        });
    }

    /**
     * Delete a task
     * @param {string} taskId - Task ID
     * @param {function} callback - Callback function
     */
    function deleteTask(taskId, callback) {
        var newTasks = [];
        
        // Legacy filter approach
        for (var i = 0; i < state.tasks.length; i++) {
            if (state.tasks[i].id !== taskId) {
                newTasks.push(state.tasks[i]);
            }
        }
        
        state.tasks = newTasks;
        
        // Callback chain (legacy pattern)
        saveTasks(function(err) {
            if (err) {
                callback(err);
                return;
            }
            updateTaskCounts(function() {
                renderTasks(function() {
                    callback(null);
                });
            });
        });
    }

    /**
     * Toggle task completion status
     * @param {string} taskId - Task ID
     * @param {function} callback - Callback function
     */
    function toggleTask(taskId, callback) {
        var task = null;
        
        // Legacy find approach
        for (var i = 0; i < state.tasks.length; i++) {
            if (state.tasks[i].id === taskId) {
                task = state.tasks[i];
                break;
            }
        }
        
        if (!task) {
            callback(new Error('Task not found'));
            return;
        }
        
        updateTask(taskId, { completed: !task.completed }, callback);
    }

    // ========================================================================
    // Filtering and Searching
    // ========================================================================
    
    /**
     * Get filtered tasks based on current state
     * @returns {array} Filtered tasks
     */
    function getFilteredTasks() {
        var filtered = [];
        var searchLower = state.searchTerm.toLowerCase();
        
        // Legacy filter approach with for loop
        for (var i = 0; i < state.tasks.length; i++) {
            var task = state.tasks[i];
            var matchesFilter = false;
            var matchesSearch = false;
            
            // Check filter
            if (state.filter === 'all') {
                matchesFilter = true;
            } else if (state.filter === 'pending' && !task.completed) {
                matchesFilter = true;
            } else if (state.filter === 'completed' && task.completed) {
                matchesFilter = true;
            }
            
            // Check search
            if (!searchLower) {
                matchesSearch = true;
            } else {
                var titleMatch = task.title.toLowerCase().indexOf(searchLower) !== -1;
                var descMatch = task.description && 
                               task.description.toLowerCase().indexOf(searchLower) !== -1;
                matchesSearch = titleMatch || descMatch;
            }
            
            if (matchesFilter && matchesSearch) {
                filtered.push(task);
            }
        }
        
        return filtered;
    }

    /**
     * Set current filter
     * @param {string} filter - Filter type (all, pending, completed)
     */
    function setFilter(filter) {
        state.filter = filter;
        
        // Update UI
        $('.filter-btn').removeClass('active');
        $('.filter-btn[data-filter="' + filter + '"]').addClass('active');
        
        renderTasks(function() {});
    }

    /**
     * Set search term
     * @param {string} term - Search term
     */
    function setSearchTerm(term) {
        state.searchTerm = term;
        renderTasks(function() {});
    }

    // ========================================================================
    // Rendering Functions
    // ========================================================================
    
    /**
     * Render all tasks to the DOM
     * Uses jQuery for DOM manipulation (legacy pattern)
     * @param {function} callback - Callback function
     */
    function renderTasks(callback) {
        var $tasksList = $('#tasksList');
        var $emptyState = $('#emptyState');
        var tasks = getFilteredTasks();
        
        // Clear existing tasks
        $tasksList.empty();
        
        if (tasks.length === 0) {
            $tasksList.hide();
            $emptyState.show();
        } else {
            $emptyState.hide();
            $tasksList.show();
            
            // Render each task using string concatenation (legacy pattern)
            // Should use template literals in modern JS
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i];
                var html = buildTaskHtml(task);
                $tasksList.append(html);
            }
        }
        
        if (typeof callback === 'function') {
            callback();
        }
    }

    /**
     * Build HTML for a single task
     * Uses string concatenation (legacy pattern - should use template literals)
     * @param {object} task - Task object
     * @returns {string} HTML string
     */
    function buildTaskHtml(task) {
        var completedClass = task.completed ? ' completed' : '';
        var checkedClass = task.completed ? ' checked' : '';
        var checkIcon = task.completed ? '<i class="fa fa-check"></i>' : '';
        
        // Legacy string concatenation (should use template literals)
        var html = '';
        html += '<div class="task-item priority-' + escapeHtml(task.priority) + completedClass + '" data-task-id="' + escapeHtml(task.id) + '">';
        html += '  <div class="task-checkbox' + checkedClass + '" data-action="toggle">';
        html += checkIcon;
        html += '  </div>';
        html += '  <div class="task-content">';
        html += '    <div class="task-header">';
        html += '      <span class="task-title">' + escapeHtml(task.title) + '</span>';
        html += '      <span class="task-priority ' + escapeHtml(task.priority) + '">' + escapeHtml(task.priority) + '</span>';
        html += '    </div>';
        
        if (task.description) {
            html += '    <p class="task-description">' + escapeHtml(task.description) + '</p>';
        }
        
        html += '    <div class="task-meta">';
        html += '      <i class="fa fa-calendar"></i>';
        html += '      <span>' + formatDate(task.createdAt) + '</span>';
        html += '    </div>';
        html += '  </div>';
        html += '  <div class="task-actions">';
        html += '    <button class="btn btn-icon btn-secondary" data-action="edit" title="Edit task">';
        html += '      <i class="fa fa-pencil"></i>';
        html += '    </button>';
        html += '    <button class="btn btn-icon btn-danger" data-action="delete" title="Delete task">';
        html += '      <i class="fa fa-trash"></i>';
        html += '    </button>';
        html += '  </div>';
        html += '</div>';
        
        return html;
    }

    /**
     * Update task count badges
     * @param {function} callback - Callback function
     */
    function updateTaskCounts(callback) {
        var countAll = state.tasks.length;
        var countPending = 0;
        var countCompleted = 0;
        
        // Legacy counting with for loop
        for (var i = 0; i < state.tasks.length; i++) {
            if (state.tasks[i].completed) {
                countCompleted++;
            } else {
                countPending++;
            }
        }
        
        // Update UI using jQuery
        $('#countAll').text(countAll);
        $('#countPending').text(countPending);
        $('#countCompleted').text(countCompleted);
        
        if (typeof callback === 'function') {
            callback();
        }
    }

    // ========================================================================
    // Modal Functions
    // ========================================================================
    
    /**
     * Open edit modal for a task
     * @param {string} taskId - Task ID
     */
    function openEditModal(taskId) {
        var task = null;
        
        // Legacy find approach
        for (var i = 0; i < state.tasks.length; i++) {
            if (state.tasks[i].id === taskId) {
                task = state.tasks[i];
                break;
            }
        }
        
        if (!task) {
            console.error('[TaskManager] Task not found:', taskId);
            return;
        }
        
        // Populate form using jQuery
        $('#editTaskId').val(task.id);
        $('#editTaskTitle').val(task.title);
        $('#editTaskDescription').val(task.description);
        $('#editTaskPriority').val(task.priority);
        
        // Show modal
        $('#editModal').addClass('show');
    }

    /**
     * Close edit modal
     */
    function closeEditModal() {
        $('#editModal').removeClass('show');
        $('#editForm')[0].reset();
    }

    // ========================================================================
    // Event Handlers
    // ========================================================================
    
    /**
     * Initialize event handlers
     * Uses jQuery event delegation (legacy pattern)
     */
    function initEventHandlers() {
        // Add task form submission
        $('#taskForm').on('submit', function(e) {
            e.preventDefault();
            
            var $form = $(this);
            var taskData = {
                title: $form.find('#taskTitle').val().trim(),
                description: $form.find('#taskDescription').val().trim(),
                priority: $form.find('#taskPriority').val()
            };
            
            if (!taskData.title) {
                alert('Please enter a task title');
                return;
            }
            
            addTask(taskData, function(err, task) {
                if (err) {
                    alert('Error adding task: ' + err.message);
                    return;
                }
                $form[0].reset();
                console.log('[TaskManager] Task added:', task.id);
            });
        });

        // Task actions (delegated events)
        $('#tasksList').on('click', '[data-action]', function(e) {
            var $target = $(this);
            var action = $target.data('action');
            var taskId = $target.closest('.task-item').data('task-id');
            
            switch (action) {
                case 'toggle':
                    toggleTask(taskId, function(err) {
                        if (err) {
                            console.error('[TaskManager] Error toggling task:', err);
                        }
                    });
                    break;
                    
                case 'edit':
                    openEditModal(taskId);
                    break;
                    
                case 'delete':
                    if (confirm('Are you sure you want to delete this task?')) {
                        deleteTask(taskId, function(err) {
                            if (err) {
                                alert('Error deleting task: ' + err.message);
                            }
                        });
                    }
                    break;
            }
        });

        // Filter buttons
        $('.filter-btn').on('click', function() {
            var filter = $(this).data('filter');
            setFilter(filter);
        });

        // Search input
        var searchTimeout = null;
        $('#searchInput').on('input', function() {
            var term = $(this).val();
            
            // Debounce search (legacy approach)
            if (searchTimeout) {
                clearTimeout(searchTimeout);
            }
            
            searchTimeout = setTimeout(function() {
                setSearchTerm(term);
            }, 300);
        });

        // Edit form submission
        $('#editForm').on('submit', function(e) {
            e.preventDefault();
            
            var taskId = $('#editTaskId').val();
            var updates = {
                title: $('#editTaskTitle').val().trim(),
                description: $('#editTaskDescription').val().trim(),
                priority: $('#editTaskPriority').val()
            };
            
            if (!updates.title) {
                alert('Please enter a task title');
                return;
            }
            
            updateTask(taskId, updates, function(err, task) {
                if (err) {
                    alert('Error updating task: ' + err.message);
                    return;
                }
                closeEditModal();
                console.log('[TaskManager] Task updated:', task.id);
            });
        });

        // Modal close buttons
        $('#closeModal, #cancelEdit').on('click', function() {
            closeEditModal();
        });

        // Close modal on backdrop click
        $('#editModal').on('click', function(e) {
            if (e.target === this) {
                closeEditModal();
            }
        });

        // Close modal on Escape key
        $(document).on('keydown', function(e) {
            if (e.key === 'Escape' && $('#editModal').hasClass('show')) {
                closeEditModal();
            }
        });
    }

    // ========================================================================
    // Initialization
    // ========================================================================
    
    /**
     * Initialize the application
     * Uses nested callbacks (callback hell - legacy pattern)
     */
    function init() {
        console.log('[TaskManager] Initializing...');
        
        // Nested callbacks - "callback hell" (legacy pattern)
        // Modern approach would use async/await or Promises
        loadTasks(function(err, tasks) {
            if (err) {
                console.error('[TaskManager] Error loading tasks:', err);
            }
            
            updateTaskCounts(function() {
                renderTasks(function() {
                    initEventHandlers();
                    
                    console.log('[TaskManager] Initialization complete');
                    console.log('[TaskManager] Loaded ' + state.tasks.length + ' tasks');
                    
                    // Log modernization message
                    console.log('%c[MODERNIZATION NOTE]', 'color: #f59e0b; font-weight: bold;');
                    console.log('This application uses legacy JavaScript patterns (ES5, jQuery 2.x)');
                    console.log('Consider migrating to:');
                    console.log('  - ES6+ syntax (const/let, arrow functions, template literals)');
                    console.log('  - Async/await instead of callbacks');
                    console.log('  - React, Vue, or vanilla JS instead of jQuery');
                    console.log('  - TypeScript for type safety');
                    console.log('  - Modern build tools (Vite, Webpack)');
                });
            });
        });
    }

    // ========================================================================
    // Public API
    // ========================================================================
    return {
        init: init,
        addTask: addTask,
        updateTask: updateTask,
        deleteTask: deleteTask,
        toggleTask: toggleTask,
        getState: function() { return state; }
    };

})(jQuery);

// ============================================================================
// Document Ready - jQuery (legacy pattern)
// Modern approach: use DOMContentLoaded or put script at end of body
// ============================================================================
$(document).ready(function() {
    TaskManager.init();
});

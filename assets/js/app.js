// Invoice Generator Application JavaScript
// Handles browser APIs and Elm port communication

(function() {
    'use strict';

    // Get saved invoice data from localStorage
    const savedData = localStorage.getItem('invoice-data');

    // Initialize Elm app with saved data (if any)
    const app = Elm.Main.init({
        node: document.getElementById('app'),
        flags: savedData
    });

    // Subscribe to save requests from Elm
    if (app.ports && app.ports.saveToLocalStorage) {
        app.ports.saveToLocalStorage.subscribe(function(data) {
            localStorage.setItem('invoice-data', data);
            console.log('Invoice saved to browser storage');

            // Optional: Show a brief success message
            alert('Invoice saved successfully!');
        });
    }

    // Subscribe to PDF download requests from Elm
    if (app.ports && app.ports.downloadPDF) {
        app.ports.downloadPDF.subscribe(function() {
            console.log('Generating PDF...');

            // Get the invoice container element
            const element = document.querySelector('.invoice-container');

            if (!element) {
                console.error('Invoice container element not found');
                return;
            }

            // Clone the element to avoid modifying the original
            const clone = element.cloneNode(true);

            // Remove all buttons and interactive elements from the clone
            const buttons = clone.querySelectorAll('button');
            buttons.forEach(btn => btn.remove());

            // Remove the last column (close button column) from the table
            const tableHeaders = clone.querySelectorAll('.invoice-table th:last-child');
            tableHeaders.forEach(th => th.remove());
            const tableCells = clone.querySelectorAll('.invoice-table td:last-child');
            tableCells.forEach(td => td.remove());

            // Remove logo upload placeholder if exists
            const logoPlaceholder = clone.querySelector('.logo-upload-placeholder');
            if (logoPlaceholder) {
                logoPlaceholder.remove();
            }

            // Remove empty notes section
            const notesSection = clone.querySelector('.invoice-notes');
            if (notesSection) {
                const notesTextarea = notesSection.querySelector('textarea');
                if (notesTextarea && (!notesTextarea.value || notesTextarea.value.trim() === '')) {
                    notesSection.remove();
                }
            }

            // Helper function to format dates from YYYY-MM-DD to "20 January 2025"
            function formatDate(dateString) {
                if (!dateString) return '';

                const months = [
                    'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'
                ];

                const parts = dateString.split('-');
                if (parts.length === 3) {
                    const year = parts[0];
                    const month = parseInt(parts[1], 10) - 1;
                    const day = parseInt(parts[2], 10);

                    return `${day} ${months[month]} ${year}`;
                }

                return dateString;
            }

            // Replace all inputs and selects with their text values
            const inputs = clone.querySelectorAll('input, textarea, select');
            inputs.forEach(input => {
                let value = input.value || '';

                // Format date inputs
                if (input.type === 'date' && value) {
                    value = formatDate(value);
                }

                // Skip empty inputs
                if (!value || value === '0' || value.trim() === '') {
                    // Check if parent row should be hidden
                    const parentRow = input.closest('.total-row');
                    if (parentRow && !parentRow.classList.contains('total-final')) {
                        // Check if this is discount/shipping/tax with 0 value
                        if (value === '0' || value === '' || value.trim() === '') {
                            parentRow.style.display = 'none';
                        }
                    }
                }

                // Replace input with span containing the text
                const span = document.createElement('span');
                span.textContent = value;
                span.style.display = 'inline';
                span.style.font = window.getComputedStyle(input).font;
                span.style.color = window.getComputedStyle(input).color;

                input.replaceWith(span);
            });

            // Adjust padding for PDF
            clone.style.padding = '30px';
            clone.style.maxWidth = 'none';
            clone.style.boxShadow = 'none';

            // PDF options
            const opt = {
                margin: [0.5, 0.5, 0.5, 0.5],  // top, right, bottom, left
                filename: 'invoice.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: {
                    scale: 2,
                    useCORS: true,
                    letterRendering: true,
                    scrollY: 0,
                    scrollX: 0
                },
                jsPDF: {
                    unit: 'in',
                    format: 'letter',
                    orientation: 'portrait',
                    compress: true
                },
                pagebreak: { mode: ['avoid-all', 'css', 'legacy'] }
            };

            // Generate and download PDF
            html2pdf().set(opt).from(clone).save().then(function() {
                console.log('PDF downloaded successfully');
            }).catch(function(error) {
                console.error('Error generating PDF:', error);
                alert('Error generating PDF. Please try again.');
            });
        });
    }

    // Subscribe to logo upload requests from Elm
    if (app.ports && app.ports.requestLogoUpload) {
        // Create a hidden file input element
        const fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.accept = 'image/*';
        fileInput.style.display = 'none';
        document.body.appendChild(fileInput);

        // Handle file selection
        fileInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(event) {
                    // Send base64 data to Elm
                    app.ports.logoSelected.send(event.target.result);
                };
                reader.readAsDataURL(file);
            }
            // Reset the input
            fileInput.value = '';
        });

        // Subscribe to the port
        app.ports.requestLogoUpload.subscribe(function() {
            fileInput.click();
        });
    }

    // Add print functionality
    window.addEventListener('keydown', function(e) {
        // Ctrl+P or Cmd+P to print
        if ((e.ctrlKey || e.metaKey) && e.key === 'p') {
            e.preventDefault();
            window.print();
        }
    });
})();

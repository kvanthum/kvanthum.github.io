// search.js
function search() {
    var searchTerm = document.getElementById("searchInput").value;
    var pages = ["1-sissejuhatus.html", "2-andmetyybid_objektityybid.html", "3-arvulised.html", "4-kategoriaalsed.html", "5-ggplot2.html", "6-tidyverse.html", "7-valim_hypoteesid.html", "8-parameetrilised_mitteparameetrilised.html", "9-arvuliste_seosed.html", "10-mittearvuliste_seosed.html", "11-lineaarsed1.html", "12-lineaarsed2.html", "13-lineaarsed_sega.html", "14-logistilised1.html", "15-logistilised2.html", "16-logistilised3_sega.html", "17-otsustuspuud.html", "18-juhumetsad.html"]; 

    var resultsContainer = document.getElementById("searchResults");
    resultsContainer.innerHTML = ""; // Clear previous search results

    pages.forEach(function(page) {
        fetch(page)
            .then(response => response.text())
            .then(html => {
                if (html.includes(searchTerm)) {
                    var link = document.createElement("a");
                    link.href = page;
                    link.textContent = page;
                    
                    resultsContainer.appendChild(link);
                    resultsContainer.appendChild(document.createElement("br"));
                }
            })
            .catch(error => console.error('Error:', error));
    });
}


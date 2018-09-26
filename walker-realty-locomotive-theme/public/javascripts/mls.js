jQuery(function() {

  function getDataFromSearch(search) {  
    // Hand back a select2 data object
    var data = {
      results: [],
      text: "text"
    };

    if (search) {
      // Going  by area, add options for zip codes, sub areas and whatever else we're given
      for (area in search) {
        data.results.push({
          text: area,
          id: "area:" + area
        });

        for (section in search[area]) {
          for (value in search[area][section]) {
            if (typeof(search[area][section][value]) == "object") {
              data.results.push({
                id: section + ":" + area + ":" + search[area][section][value]["id"],
                text: search[area][section][value]["text"],
                type: section,
                area: area
              });
            } else {
              data.results.push({
                id: section + ":" + area + ":" + search[area][section][value],
                text: search[area][section][value],
                type: section,
                area: area
              });
            }

            
          }
        }
      }
    }
    return data;
  }

  function setAreaData(selector) {
    var url = "/search/autocomplete";

    // Fetch our results
    $.ajax({
      type: 'GET',
      url: url,
      async: true,
      jsonpCallback: 'jsonCallback',
      contentType: "application/json",
      dataType: 'jsonp',
      success: function(json) {
        jQuery(selector).select2( {
          data: getDataFromSearch(json),
          placeholder: "Enter a city, neighborhood, street address, street, or zip code",
          minimumInputLength: 2,
          multiple: true,
          width: "100%",
          formatResult: formatSearchTerm,
          dropdownAutoWidth: true
        });
      },
      error: function(e) {
         console.log(e.message);
      }
    });
  }

  function formatSearchTerm(area) {
    if (area.type) {
      return area.text + " <small><i> " + area.type.
        replace(/^[a-z]/, function(m){ return m.toUpperCase() }).
        replace(/_[a-z]/, function(m){ return " " + m[1].toUpperCase() }) +
        " in " + area.area + "</i></small>";
    } else {
      return area.text + " <small><i>Areas</i></small>";
    }
  }

  setAreaData("#mls-areas");
});

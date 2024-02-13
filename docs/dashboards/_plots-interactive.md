For static dashboards, there are pros and cons to using JavaScript-based plots. While JavaScript-based plots handle resizing to fill their container better that static plots, they also embed the underlying data directly in the published page (one copy of the dataset per plot) which can lead to slower load times.

For interactive Shiny dashboards all plot types are sized dynamically so resizing behavior is not a concern as it is with static dashboards.


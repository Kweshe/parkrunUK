# Bunching behaviour in Parkrun

### Project overview

This analysis explores seasonality effects and bunching behavior in parkrun events, revealing significant clustering around specific minute intervals.

### Data source
The dataset used for this analysis is the "Parkrun_data.dta" file, which comprises the results of a serie of 5-kilometre runs from 10 parkrun clubs in the United Kingdom. 

Number of observations: 473,759


### Questions explored and methodology

- A fixed effect model was used to test for seasonal pattern in runners finishing time.
- Bunching regions were constructed to test the existence of bunching behaviour in finishing time, using t-test. 
- A logistic regression was used to detect gender differences in reference dependent behaviour. 

### Software
STATA for data cleaning and analysis


### Findings
- We found strong evidence of a seasonality effect, as the average finishing time significantly decreases during winter. This may be attributed to the fact that only the most athletic individuals tend to participate during this period.
- Runners use round finishing time as reference points as there is bunching around theses points. The results also suggest that gender affects bunching behaviour
  

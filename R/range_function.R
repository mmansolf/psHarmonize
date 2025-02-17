#' Range function. To be called by harmonization function.
#'
#' @param data Data to be modified
#' @param min_max_range Range of allowed values
#' @param new_var New variable
#'
#' @return
#' @export
#'
#' @importFrom dplyr case_when
#'
#' @examples
#'
range_function <- function(data = temp_dataset,
                           min_max_range = possible_range,
                           new_var = item)
{

  ## Get numbers
  min_num <- stringr::str_extract(min_max_range, '[:digit:]+(?=,)') %>%
    as.numeric()

  max_num <- stringr::str_extract(min_max_range, '(?<=,)[:digit:]+') %>%
    as.numeric()


  ## Get directions

  direction_first <- stringr::str_extract(min_max_range, '^[:punct:]')

  direction_last <- stringr::str_extract(min_max_range, '[:punct:]$')

  convert <- function(input)
  {
    case_when(input == '[' ~ '>=',
              input == '(' ~ '>',
              input == ']' ~ '<=',
              input == ')' ~ '<'
    )
  }

  direction_first <- convert(direction_first)
  direction_last <- convert(direction_last)

  range_function2 <- function(input)
  {

    text_first <- paste0(input, ' ', direction_first, ' ', min_num)
    text_last <- paste0(input, ' ', direction_last, ' ', max_num)

    case_when(

      eval(parse(text = text_first)) &
        eval(parse(text = text_last))
      ~ input

    )

  }

  new_value <- sapply(data[[new_var]], range_function2)



  ## Recording the number of values set to missing in error log

  orig_na <- sum(is.na(data[[new_var]]))

  new_value_na <- sum(is.na(new_value))

  ## Saving items into list, then return list

  range_result_list <- list(new_value = new_value,
                            range_set_to_na = (new_value_na - orig_na))

  return(range_result_list)

}


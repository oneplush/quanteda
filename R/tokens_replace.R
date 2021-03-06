#' Replace tokens in a tokens object
#'
#' Substitute token types based on vectorized one-to-one matching. Since this
#' function is created for lemmatization or user-defined stemming. It support
#' substitution of multi-word features by multi-word features, but substitution
#' is fastest when `pattern` and `replacement` are character vectors
#' and `valuetype = "fixed"` as the function only substitute types of
#' tokens. Please use [tokens_lookup()] with `exclusive = FALSE`
#' to replace [dictionary] values.
#' @param x [tokens] object whose token elements will be replaced
#' @param pattern a character vector or list of character vectors.  See
#'   [pattern] for more details.
#' @param replacement a character vector or (if `pattern` is a list) list
#'   of character vectors of the same length as `pattern`
#' @inheritParams valuetype
#' @param verbose print status messages if `TRUE`
#' @export
#' @seealso tokens_lookup
#' @examples
#' toks1 <- tokens(data_corpus_irishbudget2010, remove_punct = TRUE)
#'
#' # lemmatization
#' infle <- c("foci", "focus", "focused", "focuses", "focusing", "focussed", "focusses")
#' lemma <- rep("focus", length(infle))
#' toks2 <- tokens_replace(toks1, infle, lemma, valuetype = "fixed")
#' kwic(toks2, "focus*")
#'
#' # stemming
#' type <- types(toks1)
#' stem <- char_wordstem(type, "porter")
#' toks3 <- tokens_replace(toks1, type, stem, valuetype = "fixed", case_insensitive = FALSE)
#' identical(toks3, tokens_wordstem(toks1, "porter"))
#' 
#' # multi-multi substitution
#' toks4 <- tokens_replace(toks1, phrase(c("Minister Deputy Lenihan")), 
#'                               phrase(c("Minister Deputy Conor Lenihan")))
#' kwic(toks4, phrase(c("Minister Deputy Conor Lenihan")))
tokens_replace <- function(x, pattern, replacement, valuetype = "glob",
                           case_insensitive = TRUE, verbose = quanteda_options("verbose")) {
    UseMethod("tokens_replace")
}

#' @export
tokens_replace.default <- function(x, pattern, replacement, valuetype = "glob",
                                   case_insensitive = TRUE, verbose = quanteda_options("verbose")) {
    stop(friendly_class_undefined_message(class(x), "tokens_replace"))
}
    
#' @export
tokens_replace.tokens <- function(x, pattern, replacement, valuetype = "glob",
                                  case_insensitive = TRUE, verbose = quanteda_options("verbose")) {
    
    x <- as.tokens(x)
    if (length(pattern) != length(replacement))
        stop("Lengths of 'pattern' and 'replacement' must be the same")
    if (!length(pattern)) return(x)
    
    type <- types(x)
    if (valuetype == "fixed" && !is.list(pattern) && !is.list(replacement)) {
        type_new <- replace_type(type, pattern, replacement, case_insensitive)
        if (!identical(type, type_new)) {
            attr(x, "types") <- type_new
            x <- tokens_recompile(x)
        }
    } else {
        attrs <- attributes(x)
        ids_pat <- pattern2list(pattern, type, valuetype, case_insensitive, 
                                attr(x, "concatenator"), keep_nomatch = FALSE)
        type <- union(type, unlist(replacement, use.names = FALSE))
        ids_repl <- pattern2list(replacement, type, "fixed", FALSE, 
                                 attr(x, "concatenator"), keep_nomatch = TRUE)
        x <- qatd_cpp_tokens_replace(x, type, ids_pat, ids_repl[attr(ids_pat, "pattern")])
        attributes(x, FALSE) <- attrs
    }
    return(x)
}


#' Replace types by patterns
#'
#' @noRd
#' @keywords internal
replace_type <- function(type, pattern, replacement, case_insensitive) {

    if (!is.character(pattern) || !is.character(replacement))
        stop("'pattern' and 'replacement' must be characters")
    if (!length(type)) return(character())
    
    # normalize unicode
    pattern <- stri_trans_nfc(pattern)
    replacement <- stri_trans_nfc(replacement)
    
    if (case_insensitive) {
        type_new <- replacement[match(stri_trans_tolower(type), stri_trans_tolower(pattern))]
    } else {
        type_new <- replacement[match(type, pattern)]
    }
    return(ifelse(is.na(type_new), type, type_new))
}

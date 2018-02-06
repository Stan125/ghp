#include <Rcpp.h>
#include <algorithm>
#include <vector>

// [[Rcpp::export]]
Rcpp::NumericVector perm_cpp(Rcpp::NumericVector perm, Rcpp::CharacterVector model_ids, Rcpp::NumericVector gofs_vector) {
  int psize = perm.size();
  Rcpp::CharacterVector perm_char = (Rcpp::CharacterVector) perm; // Convert perms to characters
  Rcpp::CharacterVector lh_names(psize); // Names for Model ID's where GOF w/ Model ID of Model w/o var should be substracted
  Rcpp::CharacterVector rh_names(psize); // Names for Model ID's which should be substracted from lh_names
  for (int i = 0; i < psize; ++i) { // Überall x einsetzen
    rh_names(i) = "x";
    lh_names(i) = "x";
  }
  for (int i = 0; i < psize; ++i) {
    Rcpp::NumericVector temp(i + 1); // temp vector that should be sorted of size i
    for (int j = 0; j <= i; ++j) {
      temp(j) = perm(j);
    }
    Rcpp::NumericVector temp_rh = Rcpp::clone(temp); // Extra temp because this has to be sorted right after the first element was excluded
    std::sort(temp.begin(), temp.end()); // Sort temp vector
    temp_rh.erase(0); // Erase first element
    std::sort(temp_rh.begin(), temp_rh.end()); // Sort temp_rh vector
    for (int j = 0; j <= i; ++j) // LHS names
      lh_names(i) += std::to_string((int) temp(j));
    for (int j = 0; j < i; ++j) // RHS names
      rh_names(i) += std::to_string((int) temp_rh(j));
    rh_names(0) = "x0";
  }

  // Placements
  int tmp_rh = 0;
  int tmp_lh = 0;
  Rcpp::NumericVector pos_lh(psize);
  Rcpp::NumericVector pos_rh(psize);
  for (int i = 0; i < model_ids.size(); ++i) {
    if (tmp_lh == psize && tmp_rh == psize) {
      break;
    }
    if (tmp_lh < psize && model_ids(i) == lh_names(tmp_lh)) {
      pos_lh(tmp_lh) = i;
      tmp_lh += 1;
      continue; // Because can't have two model names in both rh_names and lh_names which are equal
    }
    if (tmp_rh < psize && model_ids(i) == rh_names(tmp_rh)) {
      pos_rh(tmp_rh) = i;
      tmp_rh += 1;
    }
  }
  Rcpp::NumericVector diffs(psize);
  for (int i = 0; i < psize; ++i)
    diffs(i) = gofs_vector(pos_lh(i)) - gofs_vector(pos_rh(i));
  return diffs;
}

/*** R
perm_cpp(perm, gofs_list$model_ids, gofs_list$gofs$mu)
*/

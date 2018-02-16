#include <Rcpp.h>
#include <algorithm>
#include <vector>

//' Core partitioning function
//'
//' Computes the corresponding difference of a model combination with or without a variable (first one in the permutation). Written in C++.
//' @param perm All permutations in a matrix
//' @param model_ids A numeric vector with unique model id's
//' @param gofs_vector A numeric vector with goodness-of-fit numbers
// [[Rcpp::export]]
Rcpp::List perm_cpp(Rcpp::NumericMatrix perms,
                             Rcpp::CharacterVector model_ids,
                             Rcpp::NumericVector gofs_vector) {
  int psize = perms.ncol();
  int pnums = perms.nrow();
  Rcpp::NumericMatrix indep_raw(pnums, psize); // Matrix for results of independent effects
  Rcpp::NumericMatrix joint_raw(pnums, psize); // Matrix for raw results of joint effects (which have to be further processed)
  Rcpp::NumericVector perm_num(psize); // This vector is filled for every permutation

  // Here the iteration over each row starts
  for (int l = 0; l < pnums; ++l) {

    // --- Initialisation ---
    perm_num = (Rcpp::NumericVector) perms(l, Rcpp::_); // Get specific permutation
    Rcpp::CharacterVector lh_names(psize); // Names for Model ID's where GOF w/ Model ID of Model w/o var should be substracted
    Rcpp::CharacterVector rh_names(psize); // Names for Model ID's which should be substracted from lh_names

    // --- Create Character Vectors ---
    // These character vectors are important because they serve as an
    // index for the differences that have to be made.
    for (int i = 0; i < psize; ++i) { // every vector is filled with x's
      rh_names(i) = "x";
      lh_names(i) = "x";
    }
    for (int i = 0; i < psize; ++i) { // here the vectors are filled ascendingly
      Rcpp::NumericVector temp(i + 1); // temp vector that should be sorted of size i
      for (int j = 0; j <= i; ++j) {
        temp(j) = perm_num(j);
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

    // --- Create Placement Vectors ---
    // This is needed to know which differences have to be computed
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
    // Differences are computed here to get raw indep and joint contributions
    Rcpp::NumericVector diffs_indep(psize);
    Rcpp::NumericVector diffs_joint(psize);
    for (int i = 0; i < psize; ++i) {
      diffs_indep(i) = gofs_vector(pos_lh(i)) - gofs_vector(pos_rh(i));
      diffs_joint(i) = gofs_vector(perm_num(0)) - diffs_indep(i); // This takes the first part of the permutation, uses it to find the gof with first effect variable and substracts from it the indep contributions
    }
    indep_raw(l, Rcpp::_) = diffs_indep;
    joint_raw(l, Rcpp::_) = diffs_joint;
  }

  // --- Calculate the average independent & joint effect contributions ---
  Rcpp::NumericVector indep_results(psize);
  Rcpp::NumericMatrix joint_allocs(psize, psize);
  int perms_per_var = pnums / psize; // How many permutations per variable?
  int nums_to_average = perms_per_var * psize;                                // How many numbers are used to compute the average - independent
  for (int i = 0; i < psize; ++i) {                                           // This iterates over all variables
    for (int j = (i * perms_per_var); j < ((i + 1) * perms_per_var); ++j) {   // This iterates over the specific rownumbers (made with i)
      int second_perm_val = perms(j, 1);                                      // Second number in permutation: important to know which joint contribution is needed
      // Independent contributions
      indep_results(i) += indep_raw(j, 0) / nums_to_average;                  // This is taken out of the loop so that we can write the following in one loops. Index 0 is taken out
      for (int l = 1; l < psize; ++l) {                                       // This iterates over the column in the rows
        indep_results(i) += indep_raw(j, l) / nums_to_average;                // This computes the average independent contribution

        // Joint contributions
        joint_allocs(second_perm_val - 1, i) += joint_raw(j, l) / nums_to_average; // This fills up the joint allocation matrix... we use the minus one so the second entry in the permutation matches up with the index of the matrix...
      }
    }
    joint_allocs(i, i) = gofs_vector(0);                                      // The diagonal of the joint allocations is always the empty model
  }

  // --- Calculate RowSums for sum joint contributions
  Rcpp::NumericVector joint_results(psize);
  for (int i = 0; i < psize; ++i)
    for (int j = 0; j < psize; ++j)
      joint_results(i) += joint_allocs(j, i);

  // -- Create a list to return to R
  Rcpp::List full_list;
  full_list["I"] = indep_results;
  full_list["J"] = joint_results;
  full_list["J_allocs"] = joint_allocs;
  return full_list;
}

/*** R
perms <- do.call(rbind, combinat::permn(7))
model_ids <- c("x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x12", "x13",
               "x14", "x15", "x16", "x17", "x23", "x24", "x25", "x26", "x27",
               "x34", "x35", "x36", "x37", "x45", "x46", "x47", "x56", "x57",
               "x67", "x123", "x124", "x125", "x126", "x127", "x134", "x135",
               "x136", "x137", "x145", "x146", "x147", "x156", "x157", "x167",
               "x234", "x235", "x236", "x237", "x245", "x246", "x247", "x256",
               "x257", "x267", "x345", "x346", "x347", "x356", "x357", "x367",
               "x456", "x457", "x467", "x567", "x1234", "x1235", "x1236", "x1237",
               "x1245", "x1246", "x1247", "x1256", "x1257", "x1267", "x1345",
               "x1346", "x1347", "x1356", "x1357", "x1367", "x1456", "x1457",
               "x1467", "x1567", "x2345", "x2346", "x2347", "x2356", "x2357",
               "x2367", "x2456", "x2457", "x2467", "x2567", "x3456", "x3457",
               "x3467", "x3567", "x4567", "x12345", "x12346", "x12347", "x12356",
               "x12357", "x12367", "x12456", "x12457", "x12467", "x12567", "x13456",
               "x13457", "x13467", "x13567", "x14567", "x23456", "x23457", "x23467",
               "x23567", "x24567", "x34567", "x123456", "x123457", "x123467",
               "x123567", "x124567", "x134567", "x234567", "x1234567")
first_two_nums <- apply(perms, 1, FUN = function(x) return((x[1] * 10) + x[2]))
sort_order <- sort(first_two_nums, index.return = TRUE)$ix
perms <- perms[sort_order, ]
gofs_vector <- c(0, 0.0242315367486177, 0.00321018229788907, 0.0133382341772934,
                 0.00026330890200583, 0.0000289304699211758, 0.00000645664777135851,
                 0.0156415202426046, 0.0286481134186548, 0.0279262783063968, 0.0242672266294022,
                 0.0242320664590392, 0.0242621662591781, 0.0369537509696897, 0.0164973663015551,
                 0.003604386008442, 0.00325928639327885, 0.00328341504930682,
                 0.017882125199963, 0.0135188772364756, 0.0133414452310304, 0.0137323637025652,
                 0.02995138635403, 0.000288809102205445, 0.000263916164884697,
                 0.0157018956303881, 0.0000480355197244756, 0.0160009161024139,
                 0.0158150142475651, 0.0321084264284819, 0.0287469983368307, 0.0286544468735621,
                 0.0286497568781567, 0.0402978947355141, 0.0279627252755395, 0.0279330858954266,
                 0.0279576491146428, 0.0417157189692007, 0.0242676084483471, 0.0243056829247642,
                 0.0369569249572652, 0.0242631742543318, 0.0371527974568908, 0.0374041873683798,
                 0.0167877396155692, 0.0164973926496292, 0.0171709295729238, 0.0322219542681303,
                 0.00364847579587638, 0.00364726447042964, 0.0179996279727033,
                 0.00338591935017654, 0.0182940441311806, 0.0179483337694839,
                 0.0135230634777123, 0.0138590569889354, 0.0299575709419236, 0.0137508138636512,
                 0.0301658137517262, 0.0299514627709101, 0.000294780078481425,
                 0.016049114742952, 0.0158927396532151, 0.016071843144061, 0.0322064449892257,
                 0.0321090040914534, 0.0322534879613135, 0.0448533261992856, 0.0287525181152056,
                 0.028747079465572, 0.0403007585733649, 0.028659133826698, 0.0405414628627887,
                 0.0405319487183527, 0.0279701306135703, 0.0279875391248748, 0.0417260626776407,
                 0.0279585995456986, 0.0418685522192354, 0.0418526186167891, 0.0243075281871961,
                 0.0371584404022369, 0.0374042313872322, 0.0374802324036061, 0.016787945219774,
                 0.0173761541214751, 0.0322529055847945, 0.0172356426679261, 0.0324774697474289,
                 0.0322460801844823, 0.00373055067590789, 0.0183938473054925,
                 0.0180793664920625, 0.0183015112704541, 0.0138725739436356, 0.0301692974373944,
                 0.0299578050470244, 0.0301797173046073, 0.0161319913790978, 0.0322073040121843,
                 0.0323294388115939, 0.0448533582220846, 0.032262781130383, 0.0450452161534074,
                 0.044890085490609, 0.0287536665886447, 0.0405425892490221, 0.0405394796747807,
                 0.0406730378149359, 0.0279891493198189, 0.0418824779954628, 0.0418579698720573,
                 0.0419443075284541, 0.0374808302684179, 0.0174295106921424, 0.0325016327574264,
                 0.0322731560452658, 0.0325690088704523, 0.0184068311895303, 0.030181997445461,
                 0.0323362562156983, 0.0450453563324447, 0.0448904673005894, 0.045050880523529,
                 0.0406771014747719, 0.0419529545779776, 0.0325855238141161, 0.0450509092711064
)
perm_cpp(perms, model_ids, gofs_vector)
# test(perms)
*/


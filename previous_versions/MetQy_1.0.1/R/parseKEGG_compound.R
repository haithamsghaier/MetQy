#' Parse the KEGG compound database
#'
#' Read the KEGG compound database text file and format it into a reference table.
#' 
#' @details 
#' The columns are automatically generated by the \code{parseKEGG_file} function into variables, 
#' which are further formatted specifically for the KEGG compound database.
#' 
#' The text file used is "\code{KEGG_path}/ligand/compound/compound". 
#' 
#' It decompresses "\code{KEGG_path}/ligand/compound.tar.gz" if needed.
#'
#' @param KEGG_path - string pointing to the location of the KEGG database parent folder.
#'
#' @param outDir    - string pointing to the output folder. Default ("output/"). \code{NULL} overwrites existing files.
#'
#' @param verbose   - logical. Should progress be printed to the screen? Default (\code{TRUE}).
#'
#' @param ...       - other arguments for \code{parseKEGG_file()}.
#'
#' @return Generates compound_reference_table (.txt & .rda; saved to \code{'outDir'}) and returns
#' a data frame with as many rows as entries and the following columns (or variables):
#' \preformatted{
#' 	 (1) ID         - C number identifier (e.g. "C00001");
#' 	 (2) NAME       - compund name(s);
#' 	 (3) FORMULA    - chemical formula;
#' 	 (4) EXACT_MASS - compound's mass;
#' 	 (5) MOL_WEIGHT - molecular weight;
#' 	 (6) REMARK     - relationship with D number and others;
#' 	 (7) REACTION   - reactions IDs (R#####) in which the compound is involved;
#' 	 (8) PATHWAY    - pathway(s) in which the compound is involved (map### and name);
#' 	 (9) MODULE     - module(s)  in which the compound is involved (M##### and name);
#' 	 (10) ENZYME    - EC numbers catalysing a reaction in which the compound is involved;
#' 	 (11) BRITE;    (12) DBLINKS;   (13) ATOM;      (14) BOND;  (15) COMMENT;
#' 	 (16) BRACKET;  (17) SEQUENCE;  (18) REFERENCE;
#' }
#' In all instances, multiple entries in a given column are separated by '[;]'.
#' EC numbers are of the form \code{'\\d[.]\\d+[.]\\d+[.]\\d+'} (e.g. '1.97.1.12')
#'
#' @export
#'
#' @seealso \link{parseKEGG_file}

############################################################################################################################################

parseKEGG_compound <- function(KEGG_path, outDir = "output", verbose = T,...){

  ####  MANAGE INPUT ----
  # CHECKS
  stopifnot(is.character(KEGG_path),length(KEGG_path)==1,dir.exists(KEGG_path))
  stopifnot((is.character(outDir)&&length(outDir)==1)||is.null(outDir))
  stopifnot(is.logical(verbose))

  # PATHS
  KEGG_path <- gsub("/$","",KEGG_path)
  if(!is.null(outDir)) outDir    <- gsub("/$","",outDir)

  # OUTPUT FOLDER
  if(!is.null(outDir)) if(!dir.exists(outDir)) dir.create(outDir)

  #### READ IN FILE ----
  if(verbose) cat("\tcompound processing...",fill = T)
  start <- Sys.time()

  #### UNTAR FILE ----
  if(!file.exists(paste(KEGG_path,"/ligand/compound/compound",sep=""))) {
    if(verbose) cat("\n\t\tDecompressing compound file...",fill = T)
    untar(paste(KEGG_path,"/ligand/compound.tar.gz",sep=""),files = "compound/compound",exdir = paste(KEGG_path,"/ligand/",sep=""))
  }

  ####  PROCESS FILE ----
  compound_file             <- paste(KEGG_path,"/ligand/compound/compound",sep="")
  compound_reference_table  <- parseKEGG_file(compound_file,verbose = verbose,...)

  ####  FORMAT TABLE                    ----
  compound_reference_table$ENTRY      <- gsubfn::strapplyc(pattern = "C\\d{5}",compound_reference_table$ENTRY,simplify = T)
  names(compound_reference_table)[1]  <- "ID"

  compound_reference_table$REACTION <- gsub(" ",";",compound_reference_table$REACTION)
  compound_reference_table$ENZYME   <- gsub(" ",";",compound_reference_table$ENZYME)

  ####  WRITE TABLE  (.txt, .rda) ----
  if(!is.null(outDir)){
    compound_reference_table_file <- paste(outDir,"/compound_reference_table.txt",sep="")
    write.table(compound_reference_table,file = compound_reference_table_file,sep = "\t",row.names = F,quote = F)

    save(compound_reference_table,file = gsub(".txt",".rda",compound_reference_table_file))
    if(verbose) cat("\t Completed in",format(difftime(Sys.time(),start,units = "mins"),digits = 4),"\n",fill = T)
  }

  ### RETURN ---
  return(compound_reference_table)
}

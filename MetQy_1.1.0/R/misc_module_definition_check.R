#' KEGG module definition processing: block formatting.
#'
#' Format the KEGG module DEFINITION for ease of analysis.
#'
#' @param DEFINITION  - string containing a KEGG module DEFINITION (logical expression using K numbers).
#'
#' @param ...  - further arguments (currently unsupported)
#'
#' @details
#' The KEGG module definition uses both spaces and plus signs to indicate \code{'AND'} operations.
#' However, the \code{'AND'} operation can be used to split the module definition into BLOCKS or to indicate
#' molecular complex composition.
#' To simplify analysis, we will use spaces ONLY to delimit KEGG module BLOCKS and the plus sign ONLY to
#' indicate molecular complexes and \code{'AND'} operations within blocks.
#'
#' @seealso \link{parseKEGG_module}
#' @export

############################################################################################################################################

misc_module_definition_check <- function(DEFINITION,...){

  # DEFINE SUBGROUPING STRUCTURE
  DEFINITION <- gsub(" ,",",",DEFINITION) # CATCH LOOSE " ," (typo in definition catched 20180228)
  DEFINITION <- gsub(", ",",",DEFINITION)
  DEFINITION <- gsub(" +"," ",DEFINITION)
  DEFINITION <- gsub(" -- "," ",DEFINITION)
  DEFINITION <- gsub("^-- ","",DEFINITION)
  DEFINITION <- gsub(" --$","",DEFINITION)

  group_index <- misc_module_subgroup_indexing(DEFINITION)
  all_chars   <- strsplit(DEFINITION,split="+")[[1]] # split all characters (with regular expression)

  #### SPLIT WHERE ZEROS MATCH SPACES: BLOCKS!
    # IF NO SPACES MATCH A ZERO, SINGLE BLOCK!
  if(length(intersect(which(group_index==0),which(all_chars==" ")))==0){
    BLOCKS <- gsub(" ","+",DEFINITION)
  }else{
    split_here  <- intersect(which(group_index==0),which(all_chars==" "))
    nBlocks     <- length(split_here)+1
    BLOCKS      <- character(nBlocks)

    for(SG in 1:nBlocks){
      if(SG==1){
        thisSubBlock <- gsub(" ","+",substr(DEFINITION,1,split_here[SG]-1))
      } else if(SG>1&&SG<nBlocks){
        thisSubBlock <- gsub(" ","+",substr(DEFINITION,split_here[SG-1]+1,split_here[SG]-1))
      } else {
        thisSubBlock <- gsub(" ","+",substr(DEFINITION,split_here[SG-1]+1,nchar(DEFINITION)))
      }
      # REMOVE BRACKETS WHEN THE LAST CLOSES THE FIRST
      chars   <- strsplit(thisSubBlock,split="+")[[1]] # split all characters
      gp_ind  <- misc_module_subgroup_indexing(chars)

      if(sum(gp_ind==0)==0&&chars[1]=="("&&chars[length(chars)]==")"){
        # YES! - BALANCED
        # --> previous assumption that if they matched, they must be removed because they are flanking block! BUt only true if there is one at beginning and one at end!
        # 20180228: ADDED CHECK TO SEE THAT THERE ARE BRACKETS AT BEGINNING AND END!
        thisSubBlock <- gsub("^[()]","",thisSubBlock)
        BLOCKS[SG]    <- gsub("[)]$","",thisSubBlock)
      }else{
        BLOCKS[SG]    <- thisSubBlock
      }
    }
  }

  DEFINITION_OUT <- paste(BLOCKS,collapse = " ")

  # TRANSFORM DEFINITION TO LOGICAL EXPRESSION
  DEFINITION_OUT <- gsub("+","&",DEFINITION_OUT,fixed = T)
  DEFINITION_OUT <- gsub(",","|",DEFINITION_OUT,fixed = T)

  return(DEFINITION_OUT)
}

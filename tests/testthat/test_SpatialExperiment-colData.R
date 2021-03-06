example(read10xVisium, echo = FALSE)

test_that("colData()<-NULL retains only sample_id & spatialDataNames fields", {
    tmp <- spe
    tmp$foo <- "foo"
    colData(tmp) <- NULL
    expect_null(tmp$foo)
    expect_identical(tmp$sample_id, spe$sample_id)
    expect_identical(spatialData(tmp), spatialData(spe))
})

test_that(paste(
    "valid colData<- without sample_id field", 
    "protects sample_id & spatialDataNames fields"), {
    tmp <- spe
    tmp$foo <- "foo"
    colData(tmp) <- DataFrame(x=seq(ncol(tmp)))
    expect_null(tmp$foo)
    expect_identical(tmp$sample_id, spe$sample_id)
    expect_equivalent(spatialData(tmp), spatialData(spe))
})

test_that("colData<- with valid sample_id field passes", {
    old <- unique(spe$sample_id)
    new <- letters[seq_along(old)]
    new <- new[match(spe$sample_id, old)]
    cd <- DataFrame(sample_id=new)
    expect_silent(colData(spe) <- cd)
})

test_that("sample_id<- needs one-to-one mapping", {
    new <- spe$sample_id; new[1] <- "foo"
    expect_error(spe$sample_id <- new)
    expect_error(spe$sample_id <- sample(spe$sample_id))
})

test_that("valid sample_id<- updates imgData", {
    old <- unique(spe$sample_id)
    new <- paste0(old, "x")
    i <- match(spe$sample_id, old)
    tmp <- spe; tmp$sample_id <- new[i]
    for (i in seq_along(old))
        expect_equivalent(
            spe[, spe$sample_id == old[i]],
            tmp[, tmp$sample_id == new[i]])
    i <- match(imgData(spe)$sample_id, old)
    expect_identical(imgData(tmp)$sample_id, new[i])
})

test_that("no duplicated columns from spatialData when adding new columns to colData", {
    colnames_old <- colnames(colData(spe))
    colData(spe)$testing <- 1
    expect_equal(colnames(colData(spe)), c(colnames_old, "testing"))
})

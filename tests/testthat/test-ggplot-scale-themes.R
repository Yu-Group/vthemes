test_that("ggplot scale themes work properly", {
  require(scales)
  require(ggplot2)

  vdiffr::expect_doppelganger("vmodern_pal1",
                              show_col(vmodern_pal()(8)))
  vdiffr::expect_doppelganger("vmodern_pal2",
                              show_col(vmodern_pal(palette = "viridis")(8)))

  plt <- ggplot(iris) +
    aes(x = Sepal.Length, y = Sepal.Width, color = Petal.Length) +
    geom_point() +
    scale_color_vmodern(discrete = FALSE)
  vdiffr::expect_doppelganger("vmodern_scale1", plt)
  plt <- ggplot(iris) +
    aes(x = Sepal.Length, fill = Species) +
    geom_density() +
    scale_fill_vmodern(discrete = TRUE)
  vdiffr::expect_doppelganger("vmodern_scale2", plt)
  plt <- ggplot(iris) +
    aes(x = Sepal.Length, y = Sepal.Width, color = as.factor(Petal.Length)) +
    geom_point() +
    scale_color_vmodern(discrete = TRUE)
  vdiffr::expect_doppelganger("vmodern_scale3", plt)
  plt <- ggplot(iris) +
    aes(x = Sepal.Length, y = Sepal.Width, color = as.character(Species)) +
    geom_point() +
    scale_color_vmodern(discrete = TRUE)
  vdiffr::expect_doppelganger("vmodern_scale4", plt)

  # returns error when run, but not within expect_error
  # plt <- ggplot(iris) +
  #   aes(x = Sepal.Length, y = Sepal.Width, color = as.character(Species)) +
  #   geom_point()
  # expect_error(plt + scale_color_vmodern(discrete = FALSE))
})

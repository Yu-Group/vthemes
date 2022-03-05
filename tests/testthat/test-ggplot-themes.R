test_that("ggplot themes work properly", {
  require(ggplot2)

  plt <- ggplot(iris) +
    aes(x = Sepal.Length, y = Sepal.Width) +
    geom_point()

  vdiffr::expect_doppelganger("theme_vmodern1",
                              plt + theme_vmodern())
  vdiffr::expect_doppelganger("theme_vmodern2",
                              plt + theme_vmodern(size_preset = "medium"))
  vdiffr::expect_doppelganger("theme_vmodern3",
                              plt + theme_vmodern(bg_color = "white"))
  vdiffr::expect_doppelganger("theme_vmodern4",
                              plt + theme_vmodern(show_ticks = FALSE))
  vdiffr::expect_doppelganger("theme_vmodern5",
                              plt + theme_vmodern(grid_color = NULL))
  vdiffr::expect_doppelganger("theme_vmodern6",
                              plt + theme_vmodern(x_text_angle = TRUE))
  vdiffr::expect_doppelganger("theme_vmodern7",
                              plt +
                                theme_vmodern(axis.text.y = element_blank()))
  expect_error(plt + theme_vmodern(size_preset = "abclarge"))

  vdiffr::expect_doppelganger("theme_blank_x", plt + theme_blank_x())
  vdiffr::expect_doppelganger("theme_blank_y", plt + theme_blank_y())
  vdiffr::expect_doppelganger("theme_blank_xy", plt + theme_blank_xy())
})

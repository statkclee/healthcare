library(magick)
library(tidyverse)
library(sketcher)

# 1. 이미지 생성 ----

yoon_image <- im_load("yoon.jpg")

fs::dir_create("yoon")

yoon_tbl <- expand_grid(line_weights  = c(1,3,5),
                        smooth_levels = c(5,3,1))

save_sketch <- function(line_weight, smooth_level) {
  sketch_image <- sketch(yoon_image,
                         style         = 1,
                         lineweight    = line_weight, 
                         smooth        = smooth_level,
  )
  
  im_save(sketch_image, name = glue::glue("sketch_{line_weight}_{smooth_level}.png"), 
          path = "yoon", format = "png")
}

map2(yoon_tbl$line_weights, yoon_tbl$smooth_levels, save_sketch)


# 2. 스케치 이미지 ----

sketch_files <- fs::dir_ls("yoon")

sketch_img <- map(sketch_files, image_read)
sketch_img <- map(sketch_img, image_rotate, degree = 180)

# 리스트를 tibble 객체로 변환
raw_img <- image_join(sketch_img)

# 전체 스케치 살펴보기
raw_img %>% 
  image_scale("150") %>% 
  image_append(stack = FALSE)

# 3. 이미지 선정 ----

for(i in 1:9) {
  image_write(sketch_img[[i]], path = glue::glue("yoon/sketch_{i}.png"), format = "png")
}

# 4. 동영상 ----

raw_reorder_img <- c(raw_img[3], raw_img[2], raw_img[1],
                     raw_img[6], raw_img[5], raw_img[4],
                     raw_img[9], raw_img[8], raw_img[7])

copyright_img <- raw_reorder_img %>% 
  image_scale("250") %>% 
  image_annotate(text     = "SI Yoon", 
                 location = "+205+220", 
                 color    = "midnightblue")

# copyright_img
si_animation <- image_animate(copyright_img, fps = 1/2)
si_animation

image_write(si_animation, path = "yoon/si_yoon.gif")

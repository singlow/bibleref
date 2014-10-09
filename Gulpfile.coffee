# Load libraries
gulp         = require 'gulp'
gutil        = require 'gulp-util'
sourcemaps   = require 'gulp-sourcemaps'
rename       = require 'gulp-rename'
uglify       = require 'gulp-uglify'
coffee       = require 'gulp-coffee'
browserSync  = require 'browser-sync'
reload       = browserSync.reload

gulp.task 'browser-sync', ->
  browserSync
    server:
      baseDir: "./dist"

gulp.task 'test', ->
  gulp.src 'test/*'
    .pipe gulp.dest('dist')
    .pipe reload({stream:true})

gulp.task 'coffee', ->
  gulp.src 'src/*.coffee'
    .pipe sourcemaps.init()
    .pipe coffee().on('error', gutil.log)
    .pipe uglify()
    .pipe sourcemaps.write()
    .pipe rename({suffix: '.min'})
    .pipe gulp.dest('dist')
    .pipe reload({stream:true})

gulp.task 'watch', ['coffee'], ->
  gulp.watch 'src/*.coffee', ['coffee']
  gulp.watch 'test/*', ['test']

gulp.task 'default', ['coffee']
gulp.task 'dev', ['coffee', 'test', 'watch', 'browser-sync']

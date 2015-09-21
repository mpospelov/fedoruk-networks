var gulp = require('gulp'),
  bower = require('gulp-bower'),
  slim = require("gulp-slim"),
  uglify = require('gulp-uglify'),
  sourcemaps = require('gulp-sourcemaps'),
  sass = require('gulp-sass'),
  transform = require('vinyl-transform'),
  coffee = require('gulp-coffee'),
  inject = require('gulp-inject'),
  gutil = require('gulp-util'),
  coffeeify = require('gulp-coffeeify'),
  browserSync = require('browser-sync').create();

gulp.task('bower', function () {
  return bower()
    .pipe(gulp.dest('.tmp/lib'));
});

gulp.task('serve', ['bower', 'slim','coffee', 'sass'], function () {
  browserSync.init({
    server: './.tmp',
    reloadDelay: 2000
  });

  gulp.watch(['src/html/*.slim'], ['slim']);
  gulp.watch(['src/javascripts/*.coffee'], ['coffee']);
  gulp.watch(['src/stylesheets/*.scss'], ['sass']);
  gulp.watch(["src/**/*"], browserSync.reload);
});

gulp.task('sass', function () {
  gulp.src('./src/stylesheets/**/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass().on('error', sass.logError))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./.tmp/stylesheets'));
});

gulp.task('compress', function () {
  return gulp.src('src/javascripts/*.js')
    .pipe(sourcemaps.init())
    .pipe(uglify())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('build/javascripts'));
});

gulp.task('slim', function () {
  gulp.src("./src/html/**/*.slim")
    .pipe(slim({
      pretty: true,
      options: "attr_list_delims={'(' => ')', '[' => ']'}"
    }))
    .pipe(gulp.dest("./.tmp/"));
});

gulp.task('coffee', function() {
  gulp.src('./src/javascripts/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest('.tmp/javascripts'))
});


gulp.task('default', ['serve']);
gulp.task('build', ['compress'])

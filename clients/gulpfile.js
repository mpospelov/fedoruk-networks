var gulp = require('gulp'),
  bower = require('gulp-bower'),
  slim = require("gulp-slim"),
  uglify = require('gulp-uglify'),
  sourcemaps = require('gulp-sourcemaps'),
  sass = require('gulp-sass'),
  coffee = require('gulp-coffee'),
  inject = require('gulp-inject'),
  gutil = require('gulp-util'),
  browserSync = require('browser-sync').create();

function browserSyncInit(baseDir, files) {
  browserSync.instance = browserSync.init(files, {
    startPath: '/', server: { baseDir: baseDir }
  });
};

gulp.task('bower', function () {
  return bower()
    .pipe(gulp.dest('.tmp/lib/'));
});

gulp.task('serve', ['coffee', 'sass'], function () {
  browserSync.init({
    server: './.tmp'
  });

  gulp.watch(['./src/html/*.slim'], ['slim']);
  gulp.watch(['./src/javascripts/*.coffee'], ['coffee']);
  gulp.watch(['./src/stylesheets/*.scss'], ['sass']);
});

gulp.task('serve:dist', ['build'], function () {
  browserSyncInit(paths.dist);
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
  gulp.src("./src/html/*.slim")
    .pipe(slim({
      pretty: true,
      options: "attr_list_delims={'(' => ')', '[' => ']'}"
    }))
    .pipe(gulp.dest("./.tmp/"));
});

gulp.task('coffee', function() {
  gulp.src('./src/javascripts/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./.tmp/javascripts'))
});

gulp.task('watch', function () {
});

gulp.task('default', ['serve']);
gulp.task('build', ['compress'])

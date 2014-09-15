FROM ruby:2.1.2-onbuild

RUN bundle package --all

EXPOSE 9292
CMD []

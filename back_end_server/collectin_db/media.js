const mongoose = require("mongoose");

const media = new mongoose.Schema({
    type: {
    type: String,
    required: true,
    enum: ["image", "video"],
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  url: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
})

module.exports = mongoose.model('media', media);


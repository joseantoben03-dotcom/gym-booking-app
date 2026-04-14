const mongoose = require('mongoose');

const slotSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      trim: true,
      default: '',
    },
    description: {
      type: String,
      trim: true,
      default: '',
    },
    date: {
      type: Date,
      required: [true, 'Date is required'],
    },
    startTime: {
      type: String,
      required: [true, 'Start time is required'],
    },
    endTime: {
      type: String,
      required: [true, 'End time is required'],
    },
    capacity: {
      type: Number,
      required: [true, 'Capacity is required'],
      min: [1, 'Capacity must be at least 1'],
    },
    bookedCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Index for fast querying by date and startTime
slotSchema.index({ date: 1, startTime: 1 });

// Virtual: isFull
slotSchema.virtual('isFull').get(function () {
  return this.bookedCount >= this.capacity;
});

// Virtual: availableSpots
slotSchema.virtual('availableSpots').get(function () {
  return Math.max(0, this.capacity - this.bookedCount);
});

module.exports = mongoose.model('Slot', slotSchema);

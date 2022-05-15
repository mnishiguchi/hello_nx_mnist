defmodule HelloNxMnist.Model do
  @moduledoc """
  The Digits Machine Learning model

  https://fly.io/phoenix-files/recognize-digits-using-ml-in-elixir/

  ## Preprocessing data

  ```
  import HelloNxMnist.Model

  {images_data, labels_data} = download_mnist

  transformed_images = transform_images(images_data)
  transformed_labels = transform_labels(labels_data)

  batch_size = 32

  batched_data =
    Enum.zip(
      transformed_images |> Nx.to_batched_list(batch_size),
      transformed_labels |> Nx.to_batched_list(batch_size)
    )

  # 80% of data for training and validation
  # 20% of unseen data for testing
  #
  #   training   1200 (64%)
  #   validation  300 (16%)
  #   test        375 (20%)
  #   ---------------------
  #   total      1875
  #
  total_count      = Enum.count(batched_data)
  training_count   = floor(0.8 * total_count)
  validation_count = floor(0.2 * training_count)

  {training_data, test_data}       = Enum.split(batched_data, training_count)
  {validation_data, training_data} = Enum.split(training_data, validation_count)
  ```
  """

  @typedoc """
  The images

  - the images as binary
  - the type of the data
    - unsigned integer
  - the shape of the data
    - 60000 images
    - 1 channel
    - 28 x 28
  """
  @type images_data :: {binary, {:u, 8}, {60000, 1, 28, 28}}

  @typedoc """
  The labels

  - the lables as binary
  - the type of the data
    - unsigned integer
  - the shape of the data
    - 60000 labels
  """
  @type labels_data :: {binary, {:u, 8}, {60000}}

  @doc """
  Downloads training data
  """
  @spec download_mnist :: {images_data, labels_data}
  def download_mnist do
    Scidata.MNIST.download()
  end

  @doc """
  Reshape images to an appropreiate representation for our model

  0. Create a one-dimensinal tensor based on the binary data and its type
  0. Reshape the tensor based on the specified shape
  0. Rescale pixel values from 0..255 to 0..1
  """
  @spec transform_images(images_data) :: Nx.Tensor.t()
  def transform_images({binary, type, shape}) do
    binary
    |> Nx.from_binary(type)
    |> Nx.reshape(shape)
    |> Nx.divide(255)
  end

  @spec heatmap_image(Nx.Tensor.t(), non_neg_integer) :: struct
  def heatmap_image(transformed_images, image_index \\ 0) do
    transformed_images
    |> Nx.slice_along_axis(image_index, 1, axis: 0)
    |> Nx.reshape({1, 1, 28, 28})
    |> Nx.to_heatmap()
  end

  @doc """
  One-hot encode the lables (10 categories)

  0. Create a one-dimensinal tensor based on the binary data and its type
  0. Reshape the tensor by adding a new axis
  0. One-hot encode the tensor
  """
  @spec transform_labels(labels_data) :: Nx.Tensor.t()
  def transform_labels({binary, type, _}) do
    binary
    |> Nx.from_binary(type)
    |> Nx.new_axis(-1)
    |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
  end
end
